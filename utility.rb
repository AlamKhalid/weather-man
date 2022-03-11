# frozen_string_literal: true

# contains utility method for loading data, and formatting date
module Utility
  # this sets the month_abbr
  def month_abbr(month_str)
    Date::ABBR_MONTHNAMES[month_str.to_i] if month_str.length.positive?
  end

  # this function loads the data from file into an array and returns it
  def load_data(cmd_line_args)
    directory = cmd_line_args[2]
    year, month_str = separate_dates(cmd_line_args[1])
    # empty array of data
    data = []
    # get selected files in directory
    begin
      files_in_dir = Dir.children(directory).select { |dir| dir.include?("#{year}_#{month_abbr(month_str)}") }
      # for each file in directory, add it to array
      # we have an array of weather data class defined above
      files_in_dir.each do |file_dir|
        File.readlines("#{directory}/#{file_dir}").drop(2).each do |line|
          weather_data = line.split(',')
          data.push(WeatherData.new(weather_data)) if !weather_data[1].nil? && weather_data[1].length.positive?
        end
      end
    rescue StandardError
      puts 'Invalid directory path'
      exit
    end
    data
  end

  # get command line date and return array containing month and year separate
  def separate_dates(date)
    year, month = date.split('/')
    return [year, ''] if month.nil?

    [year, month]
  end

  # check if month is provided for -a -c
  def month_provided?(month_str)
    if month_str.length.zero?
      puts 'Please provide month along with year in following format: 2002/06'
      return false
    end
    true
  end

  # outputs date nicely
  def format_date(date)
    date_splitted = date.split('-')
    "#{Date::MONTHNAMES[date_splitted[1].to_i]} #{date_splitted[2]}"
  end
end
