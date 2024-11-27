# frozen_string_literal: true

# AWS Cognito API worker to manage user permissions
class AwsCognitoApiWorker < BaseCognitoApiWorker
  def perform(username, old_permissions, new_permissions)
    old_permissions.each do |permission|
      RemoveUserFromGroupWorker.perform_async(permission, username)
    end

    new_permissions.each do |permission|
      AddUserToGroupWorker.perform_async(permission, username)
    end
  end
end
