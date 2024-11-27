# frozen_string_literal: true

# Worker to remove user from a group
class RemoveUserFromGroupWorker
  def perform(group_name, username)
    AwsCognitoService.new(
      action: :remove_user_from_group,
      group_name: group_name,
      username: username
    ).manage_user
  end
end
