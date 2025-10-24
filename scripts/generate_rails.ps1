param(
  [switch]$SkipBundle
)

$ErrorActionPreference = 'Stop'

function Ensure-Docker {
  try { docker info | Out-Null } catch {
    Write-Error 'Docker Desktop is not running. Please start it and try again.'; exit 1
  }
}

function Ensure-ApiDir {
  if (!(Test-Path 'api')) { New-Item -ItemType Directory -Path 'api' | Out-Null }
}

function Rails-New {
  Push-Location 'api'
  try {
    if (Test-Path 'Gemfile') {
      Write-Host 'Rails app already exists in ./api; skipping generation.'
      return
    }
    docker run --rm -v "${PWD}:/app" -w /app ruby:3.3 bash -lc 'gem install bundler rails -N && /usr/local/bundle/bin/rails new . --api -T --database=postgresql'
  } finally { Pop-Location }
}

function Patch-DatabaseYml {
  $dbFile = 'api/config/database.yml'
  if (!(Test-Path $dbFile)) { return }
  (Get-Content $dbFile) |
    ForEach-Object {
      $_ -replace 'host: .*', 'host: <%= ENV.fetch("DB_HOST", "localhost") %>' `
         -replace 'username: .*', 'username: <%= ENV.fetch("DB_USERNAME", "postgres") %>' `
         -replace 'password: .*', 'password: <%= ENV.fetch("DB_PASSWORD", "postgres") %>'
    } | Set-Content $dbFile
}

function Append-Gems {
  $gemfile = 'api/Gemfile'
  if (!(Test-Path $gemfile)) { return }
  $append = @'

gem "bcrypt", "~> 3.1"        # has_secure_password
gem "jwt", "~> 2.7"            # token JWT
gem "kaminari", "~> 1.2"       # pagination
gem "rack-cors", "~> 2.0"      # CORS
gem "graphql", "~> 2.3"        # optional GraphQL

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "shoulda-matchers", "~> 6.4"
  gem "webmock", "~> 3.23"
end

group :development do
  gem "graphiql-rails", "~> 1.9"
end
'@
  Add-Content -Path $gemfile -Value $append
}

function Enable-CORS {
  $corsFile = 'api/config/initializers/cors.rb'
  if (!(Test-Path $corsFile)) { return }
  $cors = @'
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
'@
  Set-Content -Path $corsFile -Value $cors
}

function Puma-BindAll {
  $puma = 'api/config/puma.rb'
  if (Test-Path $puma) {
    (Get-Content $puma) -replace "^#?\s*bind\s+.*$", "bind 'tcp://0.0.0.0:3000'" | Set-Content $puma
  }
}

function Bundle-Install {
  if ($SkipBundle) { return }
  docker run --rm -v "${PWD}/api:/app" -w /app ruby:3.3 bash -lc '/usr/local/bundle/bin/bundle install'
}

Ensure-Docker
Ensure-ApiDir
Rails-New
Patch-DatabaseYml
Append-Gems
Enable-CORS
Puma-BindAll
Bundle-Install

Write-Host "`nOK. Rails base created/updated in ./api"
Write-Host 'To start: docker compose up --build'
