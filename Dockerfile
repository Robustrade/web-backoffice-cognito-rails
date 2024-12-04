FROM ruby:3.1.0-slim
# Install system dependencies required for building Ruby gems
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN gem install rails --version 7.1.5
RUN bundle install

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

