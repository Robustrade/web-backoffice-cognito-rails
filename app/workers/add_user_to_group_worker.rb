# frozen_string_literal: true

# Worker to add user to a group
class AddUserToGroupWorker < BaseCognitoApiWorker
  def perform(group_name, username, user_pool_id)
    AwsCognitoService.new(
      action: :add_user_to_group,
      group_name: group_name,
      user_pool_id: user_pool_id,
      username: username
    ).manage_user
  end
end
