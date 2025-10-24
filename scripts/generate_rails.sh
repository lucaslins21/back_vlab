#!/usr/bin/env bash
set -euo pipefail

if ! docker info >/dev/null 2>&1; then
  echo "Docker Desktop is not running. Start it and try again." >&2
  exit 1
fi

mkdir -p api

if [ ! -f api/Gemfile ]; then
  docker run --rm -v "${PWD}/api:/app" -w /app ruby:3.3 bash -lc "gem install bundler rails -N && rails new . --api -T --database=postgresql"
fi

# Patch database.yml to use env vars
db_file="api/config/database.yml"
if [ -f "$db_file" ]; then
  sed -i.bak -E 's/host: .*/host: <%= ENV.fetch("DB_HOST", "localhost") %>/' "$db_file"
  sed -i.bak -E 's/username: .*/username: <%= ENV.fetch("DB_USERNAME", "postgres") %>/' "$db_file"
  sed -i.bak -E 's/password: .*/password: <%= ENV.fetch("DB_PASSWORD", "postgres") %>/' "$db_file"
fi

cat >> api/Gemfile <<'RUBY'

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
RUBY

cat > api/config/initializers/cors.rb <<'RUBY'
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
RUBY

if [ -f api/config/puma.rb ]; then
  if ! grep -q "0.0.0.0" api/config/puma.rb; then
    echo "bind 'tcp://0.0.0.0:3000'" >> api/config/puma.rb
  fi
fi

docker run --rm -v "${PWD}/api:/app" -w /app ruby:3.3 bash -lc "bundle install"

echo "OK. Rails base created/updated in ./api"
echo "To start: docker compose up --build"

