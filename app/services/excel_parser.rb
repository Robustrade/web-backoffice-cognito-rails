# frozen_string_literal: true

require 'roo'

# ExcelParser class to parse the excel file and get the permissions
class ExcelParser
  attr_reader :file, :email, :xlsx

  def initialize(file, email)
    @file = file
    @email = email
    @xlsx = Roo::Spreadsheet.open(file)
  end

  def feth_roles
    sheet = xlsx.sheet(xlsx.sheets.first)
    headers = sheet.row(1)
    indices = get_indices(headers, ['Email', 'Role (Backoffice)', 'New Role (Backoffice)'])

    row = find_role_row(sheet, indices)

    row ? [row[indices[:old_role]], row[indices[:new_role]]] : []
  end

  def get_indices(headers, columns)
    columns.each_with_object({}) do |column, hash|
      hash[column.downcase.gsub(' ', '_').to_sym] = headers.index(column)
    end
  end

  def find_role_row(sheet, indices)
    sheet.drop(1).find do |r|
      r[indices[:email]] == email &&
        r[indices[:new_role]] &&
        r[indices[:old_role]]
    end
  end

  def get_permissions(old_role, new_role)
    sheet = xlsx.sheet(xlsx.sheets[1])
    headers = sheet.row(1)
    indices = get_indices(headers, [old_role, new_role, 'Permissions'])

    permissions = extract_permissions(sheet, indices)

    { success: true, old_permissions: permissions[:old], new_permissions: permissions[:new] }
  end

  def extract_permissions(sheet, indices)
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
    old_role, new_role = feth_roles
    if old_role.nil? || new_role.nil?
      return {
        success: false,
        message: "Permission request data with the email #{email} not found or either of old role and new role is not present"
      }
    end

    get_permissions(old_role, new_role)
  end
end
