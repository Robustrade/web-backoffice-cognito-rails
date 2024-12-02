Steps to setup repository and dependencies

Prerquisites and Dependencies:
- Ruby - 3.1.0
- Rails - 7.1.5
- Redis
- Sidekiq
- Nginx - web proxy (or anyother related service)

Environment Variables:
- the list of required environment variables have been listed in `.env.example` file present in the root directory of the application

Steps to setup the repository:
1. Clone the repository from `git@github.com:Robustrade/web-backoffice-cognito-rails.git`
2. Run `rails db:create` to create database
3. Run `bundle install` to install all the required gems
4. To start rails server:
  a. in development, staging mode: `rails server -b <0.0.0.0> -d`
    -b - for port binding as per proxy configuration
    -d - for execution in deamon mode
  b. in production, `rails server -b 0.0.0.0 -d ENV=production`
5. run `redis` and `sidekiq`
