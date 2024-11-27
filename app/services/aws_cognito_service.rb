class AwsCognitoService
  attr_reader :group_name, :role_arn, :username, :action, :user_pool_id, :cognito

  def initialize(
    group_name: nil,
    role_arn: nil,
    username: nil,
    action: nil,
    user_pool_id: nil
  )
    @group_name = group_name
    @role_arn = role_arn
    @username = username
    @action = action
    @user_pool_id = user_pool_id
    @cognito = Aws::CognitoIdentityProvider::Client.new(region: ENV['AWS_REGION'])
  end

  def create_group(description = nil, precedence = nil)
    response = cognito.create_group({
                                      group_name: group_name,
                                      user_pool_id: user_pool_id || ENV['AWS_USER_POOL_ID'],
                                      description: description,
                                      precedence: precedence
                                    })
    {
      success: true,
      group_name: response[:group][:group_name],
      user_pool_id: response[:group][:user_pool_id],
      description: response[:group][:description]
    }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def manage_user
    send(action.to_sym)

    { success: true, message: 'User updated successfully!' }
  rescue StandardError => e
    { success: false, error: e }
  end

  def find_username(email)
    response = cognito.list_users({user_pool_id: user_pool_id || ENV['AWS_USER_POOL_ID'],filter: "email = \"#{email}\"",})
    return { success: false, error: 'User not found with the given mail' } if response[:users].empty?

    { success: true, username: response[:users].first[:username] }
  rescue StandardError => e
    { success: false, error: e }
  end

  private

  def add_user_to_group
    cognito.admin_add_user_to_group({
                                      user_pool_id: user_pool_id || ENV['AWS_USER_POOL_ID'],
                                      username: username,
                                      group_name: group_name
                                    })
  end

  def remove_user_from_group
    cognito.admin_remove_user_from_group({
                                           user_pool_id: user_pool_id || ENV['AWS_USER_POOL_ID'],
                                           username: username,
                                           group_name: group_name
                                         })
  end
end
