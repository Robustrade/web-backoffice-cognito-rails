require 'rails_helper'

RSpec.describe ParamsValidator do
  let(:valid_data) do
    {
      email: 'test@example.com',
      file: 'test.csv',
      user_pool_id: 'us-east-1_testpool'
    }
  end

  describe '#initialize' do
    it 'sets data and action attributes' do
      validator = described_class.new(valid_data, 'process_file_data')
      expect(validator.data).to eq(valid_data)
      expect(validator.action).to eq('process_file_data')
    end
  end

  describe '#validate' do
    context 'when action is process_file_data' do
      let(:validator) { described_class.new(valid_data, 'process_file_data') }

      it 'validates successfully with all required fields' do
        validator.validate
        expect(validator.errors).to be_empty
      end

      it 'adds error when email is missing' do
        data = valid_data.merge(email: nil)
        validator = described_class.new(data, 'process_file_data')
        validator.validate
        expect(validator.errors[:email]).to include('is required')
      end

      it 'adds error when file is missing' do
        data = valid_data.merge(file: nil)
        validator = described_class.new(data, 'process_file_data')
        validator.validate
        expect(validator.errors[:file]).to include('is required')
      end

      it 'adds error when user_pool_id is missing' do
        data = valid_data.merge(user_pool_id: nil)
        validator = described_class.new(data, 'process_file_data')
        validator.validate
        expect(validator.errors[:user_pool_id]).to include('is required')
      end

      it 'adds multiple errors when all fields are missing' do
        validator = described_class.new({}, 'process_file_data')
        validator.validate
        expect(validator.errors.messages.keys).to match_array(%i[email file user_pool_id])
      end
    end
  end

  describe '#valid?' do
    it 'returns true when all validations pass' do
      validator = described_class.new(valid_data, 'process_file_data')
      expect(validator.valid?).to be true
    end

    it 'returns false when validations fail' do
      validator = described_class.new({}, 'process_file_data')
      expect(validator.valid?).to be false
    end
  end

  describe '#errors' do
    it 'returns ActiveModel::Errors instance' do
      validator = described_class.new(valid_data, 'process_file_data')
      expect(validator.errors).to be_an_instance_of(ActiveModel::Errors)
    end

    it 'maintains errors between validation calls' do
      validator = described_class.new({}, 'process_file_data')
      validator.valid?
      expect(validator.errors).not_to be_empty
      expect(validator.errors.messages.keys).to match_array(%i[email file user_pool_id])
    end
  end
end
