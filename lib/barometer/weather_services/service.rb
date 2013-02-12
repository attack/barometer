require 'rubygems'
require 'httparty'

module Barometer
  #
  # Service Class
  #
  # This is a base class for creating alternate weather api-consuming
  # drivers.  Each driver inherits from this class.  This class creates
  # some default behaviours, but they can easily be over-ridden.
  #
  # Basically, all a service is required to do is take a query
  # (ie "Paris") and return a complete Barometer::Measurement instance.
  #
  class WeatherService
    # all service drivers will use the HTTParty gem
    include HTTParty

    def self.services=(services)
      @@services = services
    end

    def self.services
      @@services
    end

    def self.register(key, service)
      @@services ||= {}
      @@services[key] = service
    end

    def self.source(key)
      @@services ||= {}
      @@services[key]
    end

    #
    # get current weather and future (forecasted) weather
    #
    def self.measure(query, metric=true)
      raise ArgumentError unless query.is_a?(Barometer::Query)

      measurement = Barometer::Measurement.new(self._source_name, metric)
      measurement.start_at = Time.now.utc

      converted_query = query.convert!(self._accepted_formats)
      if converted_query
        measurement.source = self._source_name
        measurement.query = converted_query.q
        measurement.format = converted_query.format
        measurement = self._measure(measurement, converted_query, metric)
      end

      measurement.end_at = Time.now.utc
      measurement
    end

    #########################################################################
    # PRIVATE
    # If class methods could be private, the remaining methods would be.
    #

    #
    # REQUIRED
    # re-defining these methods will be required
    #

    def self._source_name; raise NotImplementedError; end
    def self._accepted_formats; raise NotImplementedError; end
    def self._fetch(query=nil, metric=true); nil; end
    def self._build_current(result=nil, metric=true); nil; end
    def self._build_forecast(result=nil, metric=true); nil; end

    #
    # PROBABLE
    # re-defining these methods is probable though not a must
    #

    # data processing stubs
    #
    def self._build_location(result=nil, geo=nil); nil; end
    def self._build_station(result=nil); Data::Location.new; end
    def self._build_links(result=nil); {}; end
    def self._build_sun(result=nil); Data::Sun.new; end
    def self._build_timezone(result=nil); nil; end
    def self._build_extra(measurement=nil, result=nil, metric=true); measurement; end
    def self._build_local_time(measurement)
      (measurement && measurement.timezone) ? Data::LocalTime.parse(measurement.timezone.now) : nil
    end

    # given the result set, return the full_timezone or local time ...
    # if not available return nil
    def self._parse_full_timezone(result=nil); nil; end
    def self._parse_local_time(result=nil); nil; end

    # this returns an array of codes that indicate "wet"
    def self._wet_icon_codes; nil; end
    # this returns an array of codes that indicate "sunny"
    def self._sunny_icon_codes; nil; end

    #
    # OPTIONAL
    # re-defining these methods will be optional
    #

    # STUB: define this method to check for the existance of API keys,
    #       this method is NOT needed if requires_keys? returns false
    def self._has_keys?; raise NotImplementedError; end

    # STUB: define this method to check for the existance of API keys,
    #       this method is NOT needed if requires_keys? returns false
    def self._keys=(keys=nil); nil; end

    # DEFAULT: override this if you need to determine if the country is specified
    def self._supports_country?(query=nil); true; end

    # DEFAULT: override this if you need to determine if API keys are required
    def self._requires_keys?; false; end

    # data accessors
    # (see the wunderground driver for an example of overriding these)
    #
    def self._current_result(data=nil); data; end
    def self._forecast_result(data=nil); data; end
    def self._location_result(data=nil); data; end
    def self._station_result(data=nil); data; end
    def self._links_result(data=nil); data; end
    def self._sun_result(data=nil); data; end
    def self._timezone_result(data=nil); data; end
    def self._time_result(data=nil); data; end

    #
    # COMPLETE
    # re-defining these methods should not be needed, as the behavior
    # can be adjusted using methods above
    #

    # this is the generic measuring and data processing for each weather service
    # driver.  this method should be re-defined if the driver in question
    # doesn't fit into "generic" (ie wunderground)
    #
    def self._measure(measurement, query, metric=true)
      raise ArgumentError unless measurement.is_a?(Barometer::Measurement)
      raise ArgumentError unless query.is_a?(Barometer::Query)

      return measurement unless self._meets_requirements?(query)

      begin
        result = _fetch(query, metric)
      rescue Timeout::Error => e
        return measurement
      end

      if result
        measurement.current = _build_current(_current_result(result), metric)
        measurement.forecast = _build_forecast(_forecast_result(result), metric)
        measurement.location = _build_location(_location_result(result), query.geo)
        measurement.station = _build_station(_station_result(result))
        measurement.links = _build_links(_links_result(result))
        measurement.current.sun = _build_sun(_sun_result(result)) if measurement.current
        measurement.timezone = _timezone(_timezone_result(result), query, measurement.location)
        if local_time = _local_time(_time_result(result), measurement)
           measurement.measured_at = local_time
           measurement.current.current_at = local_time
        end
        measurement = _build_extra(measurement, result, metric)
      end

      measurement
    end

    # either get the timezone based on coords, or build it from the data
    #
    def self._timezone(result=nil, query=nil, location=nil)
      if full_timezone = _parse_full_timezone(result)
        full_timezone
      elsif query && query.timezone
        query.timezone
      elsif Barometer.enhance_timezone && location &&
            location.latitude && location.longitude
        WebService::Timezone.fetch(location.latitude, location.longitude)
      else
        _build_timezone(result)
      end
    end

    # return the current local time (as Data::LocalTime)
    #
    def self._local_time(result, measurement=nil)
      _parse_local_time(result) || _build_local_time(measurement)
    end

    def self._meets_requirements?(query=nil)
      self._supports_country?(query) && (!self._requires_keys? || self._has_keys?)
    end

  end
end
