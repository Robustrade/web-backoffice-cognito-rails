# frozen_string_literal: true

require 'roo'

# ExcelParser class to parse the excel file and get the permissions
class ExcelParser
  class InvalidFileError < StandardError; end
  class SheetNotFoundError < StandardError; end
  class HeadersMissingError < StandardError; end

  attr_reader :file, :email, :xlsx

  def initialize(file, email)
    @file = file
    @email = email
    @xlsx = Roo::Spreadsheet.open(file)
  rescue Roo::Error => e
    raise InvalidFileError, "Invalid excel file: #{e.message}"
  end

  def fetch_roles
    sheet = xlsx.sheet(xlsx.sheets.first)
    raise SheetNotFoundError, 'Excel file must contain at least one sheet' if sheet.nil?

    headers = sheet.row(1)
    required_columns = ['Email', 'Role (Backoffice)', 'New Role (Backoffice)']
    missing_headers = required_columns - headers
    raise HeadersMissingError, 'Excel file must contain headers' if missing_headers.any?

    indices = get_indices(headers, ['Email', 'Role (Backoffice)', 'New Role (Backoffice)'])

    row = fetch_role_row(sheet, indices)

    row ? [row[indices[:role_backoffice]], row[indices[:new_role_backoffice]]] : []
  end

  def get_indices(headers, columns, dynamic: false)
    if dynamic
      { old_role: headers.index(columns[0]), new_role: headers.index(columns[1]),
        permissions: headers.index(columns[2]) }
    else
      columns.each_with_object({}) do |column, hash|
        hash[column.parameterize(separator: '_').to_sym] = headers.index(column)
      end
    end
  end

  def fetch_role_row(sheet, indices)
    sheet.drop(1).find do |r|
      r[indices[:email]] == email &&
        r[indices[:role_backoffice]].present? &&
        r[indices[:new_role_backoffice]].present?
    end
  end

  def fetch_permissions(old_role, new_role)
    sheet = xlsx.sheet(xlsx.sheets[1])
    raise SheetNotFoundError, 'Backoffice Role Definition sheet not found' if sheet.nil?

    headers = sheet.row(1)
    indices = get_indices(headers, [old_role, new_role, 'Permissions'], dynamic: true)
    permissions = extract_permissions_from_sheet(sheet, indices)

    { success: true, old_permissions: permissions[:old], new_permissions: permissions[:new] }
  end

  def extract_permissions_from_sheet(sheet, indices)
    response = { old: [], new: [] }

    sheet.drop(1).each do |row|
      case [row[indices[:old_role]], row[indices[:new_role]]]
      when [nil, 'X']
        response[:new] << row[indices[:permissions]]
      when ['X', nil]
        response[:old] << row[indices[:permissions]]
      end
    end

    response
  end

  def parse
    old_role, new_role = fetch_roles
    if old_role.nil? || new_role.nil?
      raise ArgumentError,
            "Permission request data with the email #{email} not found or either of old role and new role is not present"
    end

    fetch_permissions(old_role, new_role)
  end
end
