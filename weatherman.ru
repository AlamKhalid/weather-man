# frozen_string_literal: true
require 'date'

class WeatherData
  # values can only be read
  attr_reader :date, :max_temp, :min_temp, :avg_temp, :max_humid, :min_humid, :avg_humid

  def initialize(date, max_temp, min_temp, min_humid, max_humid, avg_humid)
    @date = date
    @max_temp = max_temp
    @min_temp = min_temp
    # finding avg temperauture
    @avg_temp = (max_temp + min_temp).to_f / 2
    @min_humid = min_humid
    @max_humid = max_humid
    @avg_humid = avg_humid
  end
end

class String
  # red colored output
  def red
    "\e[31m#{self}\e[0m"
  end

  # blue colored output
  def blue
    "\e[34m#{self}\e[0m"
  end
end

# main class
class WeatherMan

  # this function loads the data from file into an array and returns it
  def load_data(directory)
    # empty array of data
    data = []
    # get selected files in directory
    files_in_dir = Dir.children(directory).select { |dir| dir.include?("#{$year}_#{$month}") }
    # for each file in directory, add it to array
    # we have an array of weather data class defined above
    files_in_dir.each do |file_dir|
      File.readlines("#{directory}/#{file_dir}").drop(2).each do |line|
        line_data = line.split(',')
        if !line_data [1].nil? && line_data [1].length.positive?
          data.push(WeatherData.new(line_data [0], line_data [1].to_i, line_data [3].to_i, line_data [7].to_i, line_data [9].to_i, line_data [8].to_i))
        end
      end
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
  def month_provided?
    if $month.length.zero?
      p 'Please provide month along with year in following format: 2002/06'
      return false
    end
    true
  end

  # outputs date nicely
  def format_date(date)
    date_splitted = date.split('-')
    "#{Date::MONTHNAMES[date_splitted[1].to_i]} #{date_splitted[2]}"
  end

  def print_results_e(data)
    # first print highest temp
    highest_temp = data.max_by(&:max_temp)
    puts "Highest: #{highest_temp.max_temp}C on #{format_date(highest_temp.date)}"
    # now lowest temp
    lowest_temp = data.min_by(&:min_temp)
    puts "Lowest: #{lowest_temp.min_temp}C on #{format_date(lowest_temp.date)}"
    # highest humid output
    highest_humid = data.max_by(&:max_humid)
    puts "Humid: #{highest_humid.max_humid}% on #{format_date(highest_humid.date)}"
  end

  def print_results_a(data)
    # first print highest temp avg
    highest_temp_avg = data.max_by(&:avg_temp)
    puts "Highest Average: #{highest_temp_avg.avg_temp}C"
    # now print lowest temperature avg
    lowest_temp_avg = data.min_by(&:avg_temp)
    puts "Lowest Average: #{lowest_temp_avg.avg_temp}C"
    # print max humid
    humid = data.max_by(&:avg_humid)
    puts "Average Humidity: #{humid.avg_humid}%"
  end

  # display for -c flag min and max values
  def print_output_c(data, order)
    # initial empty string
    str_output = +''
    # get date in int to be printed at start
    date_int = data.date.split('-')[2]
    # append zero if needed
    str_output << '0' if date_int.length == 1
    str_output << date_int << ' '
    # for max temperatures
    if order == 'max'
      data.max_temp.times do
        str_output << '+'.red
      end
      str_output << " #{data.max_temp}C"
    # for min temperatures
    else
      data.min_temp.times do
        str_output << '+'.blue
      end
      str_output << " #{data.min_temp}C"
    end
    puts str_output
  end

  def print_results_c(data)
    puts "#{Date::MONTHNAMES[$month_int]} #{$year}"
    data.each do |d|
      # max temperature
      print_output_c(d, 'max')
      # min temperature
      print_output_c(d, 'min')
    end
  end

  # main driver program
  def main(argv)
    if argv.length == 3
      # get month and year separated from command line
      $year, $month_int = separate_dates(argv[1])
      # get abbrevated month name from int value
      $month = Date::ABBR_MONTHNAMES[$month_int] if $month_int.to_s.length.positive?
      # case on flag value: -e, -a, -c
      case argv[0]
      when '-e'
        # first load data
        data = load_data(argv[2])
        # then print
        print_results_e(data)
      when '-a'
        # since month is necessary for this, check if it is provided or not
        return unless month_provided?

        # first load data then print
        data = load_data(argv[2])
        print_results_a(data)
      when '-c'
        # since month is necessary for this, check if it is provided or not
        return unless month_provided?

        # first load data then print
        data = load_data(argv[2])
        print_results_c(data)
      else
        # default case
        # invalid choice case
        p 'Invalid choice. Please use -e | -a | -c'
      end
    else
      # prompt user for appropriate command line arguments
      puts (<<~FORMAT)

      Please provide 3 command line arguments in the following format
      ruby appname.ru -e 2002 /path/to/filesFolder
      -e = Highest/Lowest Tmperature for a year
      -a = Average Temperatire for a month
      -c = Horizontal Chart day-wise for a month
      FORMAT
    end
  end
end

WeatherMan.new.main(ARGV)
