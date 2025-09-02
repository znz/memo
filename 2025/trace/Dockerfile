FROM ruby:3.4.5-slim
ADD Gemfile* /app/
WORKDIR /app
RUN bundle install
ADD config.ru /app/
CMD ["rackup", "-o", "0.0.0.0", "-p", "3000"]
