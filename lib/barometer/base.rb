module Barometer
  class Base
    attr_reader :query, :weather

    def initialize(query)
      @query = Barometer::Query.new(query)
      @weather = Barometer::Weather.new
    end

    def measure(metric=nil)
      @weather.start_at = Time.now.utc

      tier = 1
      until @weather.success?
        Utils::ConfigReader.each_service(tier) do |source, config|
          options = { :metric => metric }
          options.merge!(config) if config
          _measure(source, options)
        end
        tier += 1
      end

      @weather.end_at = Time.now.utc
      @weather
    end

    private

    def _measure(source, options)
      response = Barometer::WeatherService.measure(source.to_sym, @query, options)
      response.weight = options[:weight] if options && options[:weight]

      @weather.responses << response
    end
  end
end
