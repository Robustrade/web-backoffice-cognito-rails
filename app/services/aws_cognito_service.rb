class AwsCognitoService
  attr_reader :role_name, :role_arn, :username, :action, :new_role_arn

  def initialize(
    role_name: nil,
    role_arn: nil,
    username: nil,
    action: nil,
    new_role_arn: nil
  )
    @role_name = role_name
    @role_arn = role_arn
    @username = username
    @action = action
    @new_role_arn = new_role_arn
  end

  def create_role
    iam = Aws::IAM::Client.new(region: ENV['AWS_REGION'])

    assume_role_policy_document = {
      Version: '2012-10-17',
      Statement: [
        {
          Effect: 'Allow',
          Principal: {
            Service: 'cognito-idp.amazonaws.com'
          },
          Action: 'sts:AssumeRoleWithWebIdentity'
        }
      ]
    }.to_json

    response = iam.create_role({
                                 role_name: role_name,
                                 assume_role_policy_document: assume_role_policy_document
                               })
    raise StandardError, 'Failed to create role' unless response.successful?

    { success: true, role_name: response.role.role_name, role_arn: response.role.arn }
  rescue StndarError => e
    { success: false, error: e }
  end

  def manage_user
    response = send(action.to_sym, role_arn, username)
    raise StandardError, 'Failed to update the user role' unless response.successful?

    { success: true }
  rescue StndarError => e
    { success: false, error: e }
  end

  def manage_permission
    case action
    when :add_role_permissions
      response = send(action.to_sym, role_arn, role_name)
    when :update_role_permission
      response = send(action.to_sym, role_arn, role_name, new_role_arn)
    end
    raise StandardError, 'Failed to update permissions to role' unless response.successful?

    { success: true }
  rescue StndarError => e
    { success: false, error: e }
  end

  private

  def add_user_to_role(role_arn, username)
    cognito = Aws::CognitoIdentityProvider::Client.new(region: ENV['AWS_REGION'])
    user_pool_id = 'us-east-1_Example'
    cognito.admin_add_user_to_group({
                                      user_pool_id: user_pool_id,
                                      username: username,
                                      group_name: role_arn # Specify the group (or role) name
                                    })
  end

  def remove_user_from_role(role_arn, username)
    cognito = Aws::CognitoIdentityProvider::Client.new(region: ENV['AWS_REGION'])
    user_pool_id = 'us-east-1_Example'
    cognito.admin_remove_user_from_group({
                                           user_pool_id: user_pool_id,
                                           username: username,
                                           group_name: role_arn
                                         })
  end

  def add_permissions_to_role(role_arn, role_name)
    # policy_arn = 'arn:aws:iam::aws:policy/AmazonS3FullAccess'
    iam.attach_role_policy({
                             role_name: role_name,
                             policy_arn: role_arn
                           })
  end

  def update_permissions_to_role(role_arn, new_role_arn, role_name)
    # Detach old policy
    iam.detach_role_policy({
                             role_name: role_name,
                             policy_arn: role_arn
                           })

    # Attach new policy
    iam.attach_role_policy({
                             role_name: role_name,
                             policy_arn: new_role_arn
                           })
  end
end
