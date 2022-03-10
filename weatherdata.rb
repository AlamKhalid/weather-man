# frozen_string_literal: true
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
