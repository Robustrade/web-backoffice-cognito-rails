class ParamsValidator
  include ActiveModel::Validations
  attr_reader :data, :action

  def initialize(data, action)
    @data = data
    @action = action
  end

  def validate
    case action
    when 'process_file_data'
      validate_process_file_data
    end
  end

  def valid?
    validate
    errors.empty?
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  private

  def validate_process_file_data
    errors.add(:email, 'is required') if data[:email].blank?
    errors.add(:file, 'is required') if data[:file].blank?
    errors.add(:user_pool_id, 'is required') if data[:user_pool_id].blank?
  end
end
