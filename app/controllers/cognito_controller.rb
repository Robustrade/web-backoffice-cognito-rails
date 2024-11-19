class CognitoController < ApplicationController
  def create_role
    response = AwsCognitoService.new(role_name: user_role_params[:role_name]).create_role
  end

  def add_user_to_role
    response = AwsCognitoService.new(
      action: :add_user_to_role,
      role_arn: user_role_params[:role_arn],
      username: user_role_params[:username]
    ).manage_user
  end

  def remove_user_from_role
    response = AwsCognitoService.new(
      action: :remove_user_from_role,
      role_arn: user_role_params[:role_arn],
      username: user_role_params[:username]
    ).manage_user
  end

  def add_role_permission
    response = AwsCognitoService.new(
      action: :add_role_permission,
      role_name: user_role_params[:role_name],
      role_arn: user_role_params[:role_arn]
    ).manage_permission
  end

  def update_role_permission
    response = AwsCognitoService.new(
      action: :update_role_permission,
      role_name: user_role_params[:role_name],
      role_arn: user_role_params[:role_arn],
      new_role_arn: user_role_params[:new_role_arn]
    ).manage_permission
  end

  private

  def user_role_params
    permit.require(:role).permit(:role_name, :role_arn, :username, :action, :new_role_arn)
  end
end
