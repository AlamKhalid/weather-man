# frozen_string_literal: true
require 'date'
require 'colorize'
require './weatherdata'

# main class
class WeatherMan
  private

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
        if !line_data [1].nil? && line_data[1].length.positive?
          data.push(WeatherData.new(line_data[0], line_data[1].to_i, line_data[3].to_i, line_data[7].to_i,
                                    line_data[9].to_i, line_data[8].to_i))
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
    if $month_int.to_s.length.zero?
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

  def calcuate_e(data)
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

  def calculate_a(data)
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
  def print_chart_c(data, variable, color)
    # initial empty string
    str_output = +''
    # get date in int to be printed at start
    date_int = data.date.split('-')[2]
    # append zero if needed
    str_output << '0' if date_int.length == 1
    str_output << date_int << ' '
    # for max temperatures
    loop_count = data.method(variable).call
    loop_count.times do
      str_output << '+'.method(color).call
    end
    str_output << " #{loop_count}C"
    puts str_output
  end

  def calculate_c(data)
    puts "#{Date::MONTHNAMES[$month_int]} #{$year}"
    data.each do |d|
      # max temperature
      print_chart_c(d, :max_temp, :red)
      # min temperature
      print_chart_c(d, :min_temp, :blue)
    end
  end

  public

  # main driver program
  def start_program(cmd_line_args)
    if cmd_line_args.length == 3
      # get month and year separated from command line
      $year, $month_int = separate_dates(cmd_line_args[1])
      # get abbrevated month name from int value
      $month = Date::ABBR_MONTHNAMES[$month_int] if $month_int.to_s.length.positive?
      # case on flag value: -e, -a, -c
      case cmd_line_args[0]
      when '-e'
        # first load data
        data = load_data(cmd_line_args[2])
        # then print
        calculate_e(data)
      when '-a'
        # since month is necessary for this, check if it is provided or not
        return unless month_provided?

        # first load data then print
        data = load_data(cmd_line_args[2])
        calculate_a(data)
      when '-c'
        # since month is necessary for this, check if it is provided or not
        return unless month_provided?

        # first load data then print
        data = load_data(cmd_line_args[2])
        calculate_c(data)
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
      -e = Highest/Lowest Temperature for a year
      -a = Average Temperature for a month
      -c = Horizontal Chart day-wise for a month
      FORMAT
    end
  end
end

WeatherMan.new.start_program(ARGV)
