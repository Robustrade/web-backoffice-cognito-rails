class CognitoController < ApplicationController
  def create_role
    response = AwsCognitoService.new(group_name: user_role_params[:group_name])
                                .create_group(user_role_params[:description], user_role_params[:precedence])

    render json: { response: response }, status: response[:success] ? 200 : 422
  end

  def add_user_to_group
    response = AwsCognitoService.new(
      action: :add_user_to_group,
      group_name: user_role_params[:group_name],
      username: user_role_params[:username],
      user_pool_id: user_role_params[:user_pool_id]
    ).manage_user

    render json: { response: response }, status: response[:success] ? 200 : 422
  end

  def remove_user_from_group
    response = AwsCognitoService.new(
      action: :remove_user_from_group,
      group_name: user_role_params[:group_name],
      username: user_role_params[:username],
      user_pool_id: user_role_params[:user_pool_id]
    ).manage_user

    render json: { response: response }, status: response[:success] ? 200 : 422
  end

  def process_file_data
    response = ProcessPermissionRequestService.new(process_data_params[:email],
                                                   process_data_params[:file], process_data_params[:user_pool_id]).call
    render json: { response: response }, status: response[:success] ? 200 : 422
  end

  private

  def user_role_params
    params.require(:role).permit(
      :group_name,
      :role_arn,
      :username,
      :action,
      :description,
      :precedence,
      :user_pool_id
    )
  end

  def process_data_params
    params.require(:data).permit(:file, :email, :user_pool_id)
  end
end
