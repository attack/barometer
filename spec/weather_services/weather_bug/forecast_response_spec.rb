require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Barometer::WeatherService
  describe WeatherBug::ForecastResponse do
    let(:current_response) { Barometer::Response.new }

    it "parses the timezones correctly" do
      current_response.timezone = 'PDT'

      payload = Barometer::Utils::Payload.new({
        "@date" => "4/13/2013 10:23:00 AM",
        "forecast" => [{"high" => "13"}]
      })
      response = WeatherBug::ForecastResponse.new(current_response).parse(payload)

      utc_starts_at = Time.utc(2013,4,13,7,0,0)
      utc_ends_at = Time.utc(2013,4,14,6,59,59)

      expect( response.forecast[0].starts_at.utc ).to eq utc_starts_at
      expect( response.forecast[0].ends_at.utc ).to eq utc_ends_at
    end
  end
end
