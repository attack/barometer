require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Barometer::WeatherService
  describe WundergroundV1::ForecastResponse do
    let(:current_response) { Barometer::Response.new }

    it "parses the timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        "simpleforecast" => { "forecastday" => [
          {
            "date" => {
              "tz_long" => 'America/Los_Angeles',
              "pretty" => '10:46 PM PDT on May 18, 2013'
            }
          }
        ]}
      })
      response = WundergroundV1::ForecastResponse.new(current_response).parse(payload)

      utc_starts_at = Time.utc(2013,5,19,5,46,0)
      utc_ends_at = Time.utc(2013,5,20,5,45,59)

      expect( response.forecast[0].starts_at.utc ).to eq utc_starts_at
      expect( response.forecast[0].ends_at.utc ).to eq utc_ends_at
      expect( response.timezone.full ).to eq 'America/Los_Angeles'
    end

    it "parses sun timezones correctly" do
      current_response.current = Barometer::Response::Current.new
      current_response.current.observed_at = Barometer::Utils::Time.parse("May 18, 10:46 AM PDT")
      payload = Barometer::Utils::Payload.new({
        "simpleforecast" => { "forecastday" => [
          {
            "date" => {
              "tz_long" => 'America/Los_Angeles',
              "pretty" => '10:46 PM PDT on May 18, 2013'
            }
          }
        ]},
          "moon_phase" => {
          "sunrise" => {
            "hour" => '7', "minute" => '59'
          },
          "sunset" => {
            "hour" => '17', "minute" => '42'
          }
        }
      })
      response = WundergroundV1::ForecastResponse.new(current_response).parse(payload)

      utc_current_sun_rise = Time.utc(2013,5,18,14,59,0)
      utc_current_sun_set = Time.utc(2013,5,19,0,42,0)
      utc_forecast_sun_rise = Time.utc(2013,5,19,14,59,0)
      utc_forecast_sun_set = Time.utc(2013,5,20,0,42,0)

      expect( response.current.sun.rise.utc ).to eq utc_current_sun_rise
      expect( response.current.sun.set.utc ).to eq utc_current_sun_set
      expect( response.forecast[0].sun.rise.utc ).to eq utc_forecast_sun_rise
      expect( response.forecast[0].sun.set.utc ).to eq utc_forecast_sun_set
    end
  end
end
