# frozen_string_literal: true

# This is the base class for all the Cognito API workers
class BaseCognitoApiWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  sidekiq_options queue: :default, retry: 5

  sidekiq_throttle(
    # Allow maximum 10 concurrent jobs of this class at a time.
    concurrency: { limit: 10 },
    # Allow maximum 25 jobs being processed within one second window.
    threshold: { limit: 20, period: 1.second }
  )

  def perform
    # pass
  end
end
