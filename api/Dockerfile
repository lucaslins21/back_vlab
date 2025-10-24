FROM ruby:3.3

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends build-essential libpq-dev nodejs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pre-copy Gemfiles for better layer caching
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'production' \
  && bundle install --jobs 4 --retry 3

# App source
COPY . .

EXPOSE 3000

CMD ["bash", "-lc", "bundle exec rails s -b 0.0.0.0 -p 3000"]
