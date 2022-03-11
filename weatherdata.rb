# frozen_string_literal: true

# to store weather data from file
class WeatherData
  # values can only be read
  attr_reader :date, :max_temp, :min_temp, :avg_temp, :max_humid, :min_humid, :avg_humid

  def initialize(weather_data)
    @date = weather_data[0]
    @max_temp = weather_data[1].to_i
    @min_temp = weather_data[3].to_i
    # finding avg temperauture
    @avg_temp = (@max_temp + @min_temp).to_f / 2
    @min_humid = weather_data[7].to_i
    @max_humid = weather_data[9].to_i
    @avg_humid = weather_data[8].to_i
  end
end
