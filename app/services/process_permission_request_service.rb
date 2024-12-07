# frozen_string_literal: true

# Purpose: This service class is responsible for processing the permission request.
# It is responsible for parsing the excel file, finding the username of the user and enqueueing the job.
class ProcessPermissionRequestService
  attr_reader :email, :file, :username, :user_pool_id

  def initialize(email, file, user_pool_id)
    @email = email
    @file = file
    @user_pool_id = user_pool_id
  end

  def call
    set_username
    resp = parse_excel
    enqueue_job(resp[:old_permissions], resp[:new_permissions])
    resp
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def set_username
    aws_response = AwsCognitoService.new(user_pool_id: user_pool_id).fetch_username(email)
    raise aws_response[:error] unless aws_response[:success]

    @username = aws_response[:username]
  end

  def parse_excel
    response = ExcelParser.new(file, email).parse
    raise response[:message] unless response[:success]

    response
  end

  def enqueue_job(old_permissions, new_permissions)
    AwsCognitoApiWorker.perform_async(username, old_permissions, new_permissions, user_pool_id)
  end
end
