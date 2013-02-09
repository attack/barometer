module Barometer
  #
  # Measurement
  # a class that holds the response from a weather service
  #
  # its main purpose is to hold all the data collected from a single weather
  # service as it is passed to the weather object
  #
  # this response includes
  # - current weather data (using the CurrentMeasurement class)
  # - forecasted weather data (an Array of instances of the ForecastMeasurement class)
  # - time_zone information (for the location in question)
  # - weather station information (for the station that gave collected the data)
  #
  class Measurement

    attr_reader :source, :weight
    attr_reader :measured_at, :utc_time_stamp
    attr_reader :current, :forecast
    attr_reader :timezone, :station, :location, :links
    attr_reader :success
    attr_accessor :metric, :query, :format
    attr_accessor :start_at, :end_at

    def initialize(source=nil, metric=true)
      @source = source
      @metric = metric
      @success = false
      @weight = 1
      @links = {}
    end

    def success!
      current && current.temperature &&
        !current.temperature.c.nil? && @success = true
    end

    def stamp!; @utc_time_stamp = Time.now.utc; end
    def success?; @success; end
    def metric?; @metric; end
    def metric!; @metric=true; end
    def imperial!; @metric=false; end
    def now; timezone ? timezone.now : nil; end

    #
    # this will tell us if the measurement is still current ... if it is still
    # current this means that the CurrentMeasurement can still used as now
    #
    # what it also means is that if you took a measurement right now (time = now)
    # and then asked if current?(time_in_future) that current? would be true for
    # any time_in_future within 4 hours of now
    #
    # where is this useful?  lets say you take the measurement now (time = now),
    # and then you want to know if self.windy?(5_hours_in_future) ... we could
    # not use the current data for this answser as the time 5_hours_in_future
    # is not current
    #
    def current?(local_time=nil)
      current_at = ((self.current && self.current.current_at) ?
        self.current.current_at : self.measured_at)

      local_time = (local_time.nil? ? current_at : Data::LocalTime.parse(local_time))
      return true unless local_time
      raise ArgumentError unless local_time.is_a?(Data::LocalTime)

      hours_still_current = 4
      difference = (local_time.diff(current_at)).to_i.abs
      difference <= (60*60*hours_still_current).to_i
    end

    #
    # Returns a forecast for a day given by a Date, DateTime,
    # Time, or a string that can be parsed to a date
    #
    def for(date=nil)
      date = @timezone.today unless date || !@timezone
      date ||= Date.today
      return nil unless (@forecast && @forecast.size > 0)

      @forecast.for(date)
    end

    #
    # accesors (with input checking)
    #

    def source=(source)
      raise ArgumentError unless source.is_a?(Symbol)
      @source = source
    end

    def utc_time_stamp=(time=Time.now.utc)
      raise ArgumentError unless time.is_a?(Time)
      @utc_time_stamp = time
    end

    def current=(current)
      raise ArgumentError unless current.is_a?(Measurement::Result)
      @current = current
      self.stamp!
      self.success!
    end

    def forecast=(forecast)
      raise ArgumentError unless forecast.is_a?(Measurement::ResultArray)
      @forecast = forecast
    end

    def timezone=(timezone)
      return unless timezone
      raise ArgumentError unless timezone.is_a?(Data::Zone)
      @timezone = timezone
    end

    def station=(station)
      raise ArgumentError unless station.is_a?(Data::Location)
      @station = station
    end

    def location=(location)
      raise ArgumentError unless location.is_a?(Data::Location)
      @location = location
    end

    def weight=(weight)
      raise ArgumentError unless weight.is_a?(Fixnum)
      @weight = weight
    end

    def links=(links)
      raise ArgumentError unless links.is_a?(Hash)
      @links = links
    end

    def measured_at=(measured_at)
      raise ArgumentError unless measured_at.is_a?(Data::LocalTime)
      @measured_at = measured_at
    end

    #
    # simple questions
    #

    def windy?(time_string=nil, threshold=10)
      time_string ||= (measured_at || now)
      local_time = Data::LocalTime.parse(time_string)

      if current?(local_time)
        return nil unless current
        current.windy?(threshold)
      else
        return nil unless forecast && (future = forecast[local_time])
        future.windy?(threshold)
      end
    end

    def day?(time_string=nil)
      time_string ||= (measured_at || now)
      local_time = Data::LocalTime.parse(time_string)

      if current?(local_time)
        return nil unless current
        current.day?(local_time)
      else
        return nil unless forecast && (future = forecast[local_time])
        future.day?(local_time)
      end
    end

    def sunny?(time_string=nil)
      time_string ||= (measured_at || now)
      local_time = Data::LocalTime.parse(time_string)
      sunny_icons = Barometer::WeatherService.source(@source)._sunny_icon_codes

      is_day = day?(local_time)
      return is_day unless is_day

      if current?(local_time)
        return nil unless current
        current.sunny?(local_time, sunny_icons)
      else
        return nil unless forecast && (future = forecast[local_time])
        future.sunny?(local_time, sunny_icons)
      end
    end

    def wet?(time_string=nil, pop_threshold=50, humidity_threshold=99)
      time_string ||= (measured_at || now)
      local_time = Data::LocalTime.parse(time_string)
      wet_icons = Barometer::WeatherService.source(@source)._wet_icon_codes

      if current?(local_time)
        return nil unless current
        current.wet?(wet_icons, humidity_threshold)
      else
        return nil unless forecast && (future = forecast[local_time])
        future.wet?(wet_icons, pop_threshold, humidity_threshold)
      end
    end

  end
end
