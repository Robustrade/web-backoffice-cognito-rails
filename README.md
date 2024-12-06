# Web Backoffice Cognito Rails

A Rails application for managing AWS Cognito user permissions and roles.

## Prerequisites

- Ruby 3.1.0
- Rails 7.1.5
- Redis
- Sidekiq
- Nginx (or any other web proxy service)

## Environment Setup

1. Clone the repository:
   - `git clone git@github.com:Robustrade/web-backoffice-cognito-rails.git`


2. Install dependencies:
   - `bundle install`


3. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Fill in all required environment variables

4. Set up credentials for production:
   - `RAILS_ENV=production rails credentials:edit`


## Running the Application

### Development

1. Start Redis server
   - `redis-server`

2. Start Sidekiq:
   - `bundle exec sidekiq`


3. Start Rails server:
   - `rails server -b 0.0.0.0 -d`


### Production

Start Rails server in production mode:
   - `RAILS_ENV=production rails server -b 0.0.0.0 -d`


## Server Options

- `-b 0.0.0.0`: Bind to all interfaces (required for proxy configuration)
- `-d`: Run in daemon mode (background)

## Additional Information

- The application requires Redis and Sidekiq for background job processing
- Nginx or similar web proxy is recommended for production deployment
- Make sure all environment variables are properly configured before starting the application

## License

   - To be Added
