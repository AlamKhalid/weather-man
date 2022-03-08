# frozen_string_literal: true

class WeatherData
  # values can only be read
  attr_reader :date, :max_temp, :min_temp, :avg_temp, :max_humid, :min_humid, :avg_humid

  def initialize(date, max_temp, min_temp, min_humid, max_humid, avg_humid)
    @date = date
    @max_temp = max_temp
    @min_temp = min_temp
    @avg_temp = (max_temp + min_temp).to_f/2
    @min_humid = min_humid
    @max_humid = max_humid
    @avg_humid = avg_humid
  end
end

class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end
end

class WeatherMan
  def self.load_data
    # empty array of data
    data = []
    files_in_dir = Dir.children(ARGV[2]).select{|dir| dir.include?($year)}
    files_in_dir.each do |file_dir|
      File.readlines("#{ARGV[2]}/#{file_dir}").drop(1).each do |line|
        arr = line.split(',')
        if !arr[1].nil? && arr[1].length.positive?
          data.push(WeatherData.new(arr[0], arr[1].to_i, arr[3].to_i, arr[7].to_i, arr[9].to_i, arr[8].to_i))
        end
      end
    end
    data
  end

  def self.separate_dates
    year, month = ARGV[1].split('/')
    return [year, nil] if month.nil?

    [year, Date::ABBR_MONTHNAMES[month.to_i - 1]]
  end

  def self.check_month_provided?
    if $month.nil?
      p 'Please provide month along with year in following format: 2002/06'
      return false
    end
    true
  end

  def self.format_date(date)
    date_splitted = date.split('-')
    "#{Date::MONTHNAMES[date_splitted[1].to_i - 1]} #{date_splitted[2]}"
  end

  def self.print_results(data)
    # first print highest temp
    highest_temp = data.max_by(&:max_temp)
    puts "Highest: #{highest_temp.max_temp}C on #{format_date(highest_temp.date)}"
    lowest_temp = data.min_by(&:min_temp)
    puts "Lowest: #{lowest_temp.min_temp}C on #{format_date(lowest_temp.date)}"
    highest_humid = data.max_by(&:max_humid)
    puts "Humid: #{highest_humid.max_humid}% on #{format_date(highest_humid.date)}"
  end

  # main driver program
  def self.main
    if ARGV.length == 3
      $year, $month = separate_dates
      case ARGV[0]
      when '-e'
        data = load_data
        print_results(data)
      when '-a'
        return unless check_month_provided?

        load_data
      when '-c'
        return unless check_month_provided?

        load_data
      else
        p 'Invalid choice. Please use -e | -a | -c'
      end
    else
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

WeatherMan.main
