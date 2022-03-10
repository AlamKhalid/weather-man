# frozen_string_literal: true

module Utility
  # this function loads the data from file into an array and returns it
  def load_data(directory, year, month)
    # empty array of data
    data = []
    # get selected files in directory
    begin
      files_in_dir = Dir.children(directory).select { |dir| dir.include?("#{year}_#{month}") }
      # for each file in directory, add it to array
      # we have an array of weather data class defined above
      files_in_dir.each do |file_dir|
        File.readlines("#{directory}/#{file_dir}").drop(2).each do |line|
          line_data = line.split(',')
          if !line_data [1].nil? && line_data[1].length.positive?
            data.push(WeatherData.new(line_data[0], line_data[1].to_i, line_data[3].to_i, line_data[7].to_i,
                                      line_data[9].to_i, line_data[8].to_i))
          end
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

    [year, month.to_i]
  end

  # check if month is provided for -a -c
  def month_provided?(month_int)
    if month_int.to_s.length.zero?
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