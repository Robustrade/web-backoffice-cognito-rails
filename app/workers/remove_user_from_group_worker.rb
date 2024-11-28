# frozen_string_literal: true

# Worker to remove user from a group
class RemoveUserFromGroupWorker < BaseCognitoApiWorker
  def perform(group_name, username, user_pool_id)
    AwsCognitoService.new(
      action: :remove_user_from_group,
      group_name: group_name,
      user_pool_id: user_pool_id,
      username: username
    ).manage_user
  end
end
