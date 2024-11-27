# frozen_string_literal: true

# Worker to add user to a group
class AddUserToGroupWorker < BaseCognitoApiWorker
  def perform(group_name, username)
    AwsCognitoService.new(
      action: :add_user_to_group,
      group_name: group_name,
      username: username
    ).manage_user
  end
end
