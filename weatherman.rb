# frozen_string_literal: true

require 'date'
require 'colorize'
require './weatherdata'
require './utility'

# main class
class WeatherMan
  include Utility
  # main driver program
  def start_program(cmd_line_args)
    if cmd_line_args.length == 3
      # get month and year separated from command line
      year, month_int = separate_dates(cmd_line_args[1])
      # get abbrevated month name from int value
      month = Date::ABBR_MONTHNAMES[month_int] if month_int.to_s.length.positive?
      # case on flag value: -e, -a, -c
      case cmd_line_args[0]
      when '-e'
        flag_e_code(cmd_line_args[2], year, month)
      when '-a'
        flag_a_code(cmd_line_args[2], month_int, year, month)
      when '-c'
        flag_c_code(cmd_line_args[2], month_int, year, month)
      else
        # default case
        # invalid choice case
        puts 'Invalid choice. Please use -e | -a | -c'
      end
    else
      # prompt user for appropriate command line arguments
      puts(<<~FORMAT)

        Please provide 3 command line arguments in the following format
        ruby appname.ru -e 2002 /path/to/filesFolder
        -e = Highest/Lowest Temperature for a year
        -a = Average Temperature for a month
        -c = Horizontal Chart day-wise for a month
      FORMAT
    end
  end

  private

  def flag_e_code(string_year_month, year, month)
    # first load data
    data = load_data(string_year_month, year, month)
    # then print
    show_highest_lowest_temp(data)
  end

  def flag_a_code(string_year_month, month_int, year, month)
    # since month is necessary for this, check if it is provided or not
    return unless month_provided?(month_int)

    # first load data then print
    data = load_data(string_year_month, year, month)
    show_avg_temp(data)
  end

  def flag_c_code(string_year_month, month_int, year, month)
    # since month is necessary for this, check if it is provided or not
    return unless month_provided?(month_int)

    # first load data then print
    data = load_data(string_year_month, year, month)
    show_horizontal_chart(data, month_int, year)
  end

  def show_highest_lowest_temp(data)
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

  def show_avg_temp(data)
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
  def draw_bars(data, variable, color)
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

  def show_horizontal_chart(data, month_int, year)
    puts "#{Date::MONTHNAMES[month_int]} #{year}"
    data.each do |d|
      # max temperature
      draw_bars(d, :max_temp, :red)
      # min temperature
      draw_bars(d, :min_temp, :blue)
    end
  end
end

WeatherMan.new.start_program(ARGV)
