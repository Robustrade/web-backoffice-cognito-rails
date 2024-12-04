require 'sidekiq'
require 'sidekiq/throttled'
require 'sidekiq/throttled/web'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['REDIS_USERNAME']}:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_DB_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB_INDEX']}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV['REDIS_USERNAME']}:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_DB_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB_INDEX']}" }
end
