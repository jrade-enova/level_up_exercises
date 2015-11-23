require './csv_utility'
require './data/hbase_service.rb'

module Library
  include HbaseService

  def self.add_data(name, data_array)
    HbaseService.put(name, data_array)
  end

  def self.get_data(name, file_system = false)
    data = file_system ? CsvUtility.read_csv(name) : HbaseService.get(name)
  end

  def self.remove_file(name)
    HbaseService.delete(name)
  end

  def self.get_data_columns(name)
    get_data(name).first.keys
  end

  def self.get_all_files_loaded
    HbaseService.scan_rowkeys
  end

  def self.merge_data(name1, name2, name1_to_name2_mapping)
    result_data = []

    common_columns = get_data_columns(name1) & get_data_columns(name2)
    current_data = get_data(name1) + get_data(name2)

    current_data.each do |data|
      data_object = {}
      data_object = data.select { |key, _| common_columns.include?(key) }
      data_object.merge!(create_hash_from_mapping(data, name1_to_name2_mapping))
      result_data << data_object if data_object.length > 0
    end

    result_data
  end

  def self.create_hash_from_mapping(hash, column_mapping)
    result_hash = {}

    column_mapping.each do |name1_col, name2_col|
      if hash.has_key?(name1_col)
        result_hash[name1_col] = hash[name1_col]
      elsif hash.has_key?(name2_col)
        result_hash[name1_col] = hash[name2_col]
      end
    end

    result_hash
  end

  def self.read_file(file, search_options, columns, file_system)
    data = get_data(file, file_system)
    data = filter_data(data, search_options) if search_options
    data = filter_columns(data, columns) if columns
    data
  end

  def self.filter_data(data, search_options)
    result_data = []
    search_keys, search_criteria = build_search_params(search_options)
    result_data = filter_data_objects(data, search_keys, search_criteria)
  end

  def self.filter_data_objects(data, search_keys, search_criteria)
    result_data = []

    data.each do |data_object|
      data_object.each do |obj_key, obj_value|
        if search_keys.include?(obj_key) && !obj_value.nil?
          matches = build_match_lambda(obj_key, obj_value, search_criteria).call
          result_data << data_object if matches
        end
      end
    end

    result_data
  end

  def self.build_search_params(search_options)
    search_keys = []
    search_criteria = []

    search_options.each do |search_key, search_value|
      search_keys << search_key
      search_criteria << parse_search_values(search_key, search_value)
    end

    return search_keys, search_criteria
  end

  def self.filter_columns(data, columns)
    return unless columns
    data.each do |data_object|
      data_object.delete_if { |key, _| !columns.include?(key) }
    end
  end

  def self.parse_search_values(key, string)
    return [key, "==", ""] if string.nil? || string.length == 0
    return [key, "=~", string.split(/=~/).last] if string.include?("=~")
    return foo(key, string)
  end

  def self.foo(key, string)
    glt_index = string.index(/[<>]/)
    operator = glt_index.nil? ? "==" : string[glt_index]
    operator += "=" if string.include?("=") && !glt_index.nil?
    [key, operator] << string.split(/[<>=]/).last
  end

  def self.build_match_lambda(object_key, value, search_criteria)
    return_lambda = lambda {return false}
    search_criteria.each do |entry|
      search_key = entry[0]
      operator = entry[1]
      criteria = entry[2]
      if search_key == object_key
        return_lambda = build_lambda(value, operator, criteria)
        break
      end
    end
    return_lambda
  end

  def self.build_lambda(value, operator, criteria)
    enclosing = operator == "=~" ? "/" : "'"
    enclosing = "" if operator.index(/[<>]/)
    value_enclosing = operator.index(/[<>]/) ? "" : "'"
    lambda {return eval "#{value_enclosing}#{value}#{value_enclosing} #{operator} #{enclosing}#{criteria}#{enclosing}"}
  end
end