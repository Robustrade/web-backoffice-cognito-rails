# frozen_string_literal: true

# This file is used to configure the AWS SDK for Ruby using the AWS SDK for Ruby V3.
if ENV['AWS_WEB_IDENTITY_TOKEN_FILE'].present?
  # Production environment using IRSA
  role_credentials = Aws::AssumeRoleWebIdentityCredentials.new(
    client: Aws::STS::Client.new(region: ENV['AWS_REGION']),
    role_arn: ENV['AWS_ROLE_ARN'],
    web_identity_token_file: ENV['AWS_WEB_IDENTITY_TOKEN_FILE'],
    role_session_name: 'WebBackofficeCognitoSession'
  )

  Aws.config.update({
                      region: ENV['AWS_REGION'],
                      credentials: role_credentials
                    })
else
  # Local development environment
  Aws.config.update({
                      region: ENV['AWS_REGION'],
                      credentials: Aws::Credentials.new(
                        ENV['AWS_ACCESS_KEY_ID'],
                        ENV['AWS_SECRET_ACCESS_KEY'],
                        ENV['AWS_SESSION_TOKEN']
                      )
                    })
end
