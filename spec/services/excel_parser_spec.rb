# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelParser do
  let(:email) { 'testuser@kulu.com' }
  let(:file) { fixture_file_upload('test_file.xlsx') }
  let(:parser) { described_class.new(file, email) }

  describe '#initialize' do
    it 'initializes with file and email' do
      expect(parser.file).to eq(file)
      expect(parser.email).to eq(email)
      expect(parser.xlsx).to be_a(Roo::Excelx)
    end
  end

  describe '#fetch_roles' do
    context 'when Excel file has valid data' do
      it 'returns old and new roles for matching email' do
        old_role, new_role = parser.fetch_roles
        expect(old_role).to eq('Customer Support L1')
        expect(new_role).to eq('Backoffice Support L1')
      end
    end

    context 'when email does not exist in sheet' do
      let(:email) { 'nonexistent@example.com' }

      it 'returns empty array' do
        expect(parser.fetch_roles).to eq([])
      end
    end
  end

  describe '#get_indices' do
    let(:headers) { ['Email', 'Role (Backoffice)', 'New Role (Backoffice)', 'Other'] }

    it 'returns correct indices for given columns' do
      columns = ['Email', 'Role (Backoffice)', 'New Role (Backoffice)']
      indices = parser.get_indices(headers, columns)

      expect(indices[:email]).to eq(0)
      expect(indices[:role_backoffice]).to eq(1)
      expect(indices[:new_role_backoffice]).to eq(2)
    end

    it 'handles missing columns' do
      columns = ['Missing Column']
      indices = parser.get_indices(headers, columns)

      expect(indices[:missing_column]).to be_nil
    end
  end

  describe '#fetch_role_row' do
    let(:sheet) do
      parser.xlsx.sheet(parser.xlsx.sheets.first)
    end
    let(:indices) { { email: 4, role_backoffice: 6, new_role_backoffice: 7 } }

    it 'finds correct row for matching email' do
      row = parser.fetch_role_row(sheet, indices)
      expect(row).to eq(['Request #8', 39.0, 'Charlotte', 'SOLIE', 'testuser@kulu.com', 'Call Center',
                         'Customer Support L1', 'Backoffice Support L1', nil, nil, nil, nil, nil, nil])
    end

    context 'when row has missing role data' do
      let(:file) { fixture_file_upload('test_file_missing_roles.xlsx') }

      it 'returns nil for incomplete data' do
        row = parser.fetch_role_row(sheet, indices)
        expect(row).to be_nil
      end
    end
  end

  describe '#parse' do
    context 'when Excel file is valid' do
      it 'returns permissions hash with success status' do
        result = parser.parse
        expect(result[:success]).to be true
        expect(result[:old_permissions]).to be_an(Array)
        expect(result[:new_permissions]).to be_an(Array)
      end
    end

    context 'when roles are not found' do
      let(:email) { 'nonexistent@example.com' }

      it 'returns error message' do
        expect { parser.parse }.to raise_error(ArgumentError)
      end
    end

    context 'when Excel file is invalid' do
      let(:file) { Rails.root.join('spec/fixtures/files/invalid.xlsx') }

      it 'raises error' do
        expect { parser.parse }.to raise_error(StandardError)
      end
    end
  end
end
