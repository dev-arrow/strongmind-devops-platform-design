# Builder
FROM ruby:3.3-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs curl

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile

# Runtime
FROM ruby:3.3-slim

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

COPY --from=builder /app /app

USER app

ENV RAILS_ENV=production

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
