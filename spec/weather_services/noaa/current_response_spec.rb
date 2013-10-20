require_relative '../../spec_helper'

module Barometer::WeatherService
  describe Noaa::CurrentResponse do
    let(:forecast_response) { Barometer::Response.new }

    it "parses the timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        "observation_time_rfc822" => "Sun, 14 Apr 2013 10:51:00 -0700",
        "observation_time" => "Last Updated on Apr 14 2013, 10:51 am PDT"
      })
      response = Noaa::CurrentResponse.new(forecast_response).parse(payload)

      utc_observed_at = Time.utc(2013,04,14,17,51,00)
      utc_stale_at = Time.utc(2013,04,14,18,51,00)

      expect( response.current.observed_at.utc ).to eq utc_observed_at
      expect( response.current.stale_at.utc ).to eq utc_stale_at
      expect( response.timezone.to_s ).to eq 'PDT'
    end
  end
end
