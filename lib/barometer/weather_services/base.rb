module Barometer
  module WeatherService
    class Base
      def initialize(source, version=nil)
        @source = source
        @service = WeatherService.source(@source, version)
      end

      def measure(query, options={})
        @response = Barometer::Response.new

        record_time do
          measure_and_record_status(query, options)
        end

        @response.weight = options.fetch(:weight, nil)
        @response.source = @source
        @response
      end

      private

      def measure_and_record_status(query, options)
        capture_status_code do
          @response = @service.call(query, options)
        end
      end

      def capture_status_code
        yield
        @response.status_code = @response.complete? ? 200 : 204
      rescue KeyRequired
        @response.status_code = 401
      rescue Query::ConversionNotPossible
        @response.status_code = 406
      rescue Query::UnsupportedRegion
        @response.status_code = 406
      rescue Timeout::Error
        @response.status_code = 408
      end

      def record_time
        response_started_at = Time.now.utc
        yield
        @response.response_started_at = response_started_at
        @response.response_ended_at = Time.now.utc
      end
    end
  end
end
