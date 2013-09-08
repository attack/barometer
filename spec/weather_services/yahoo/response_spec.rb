require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Barometer::WeatherService
  describe Yahoo::Response do
    it "parses the timezones correctly for current weather" do
      payload = Barometer::Utils::Payload.new({
        "item" => {
          "pubDate" => "Sun, 14 Apr 2013 1:24 pm PDT"
        }
      })
      response = Yahoo::Response.new.parse(payload)

      utc_observed_at = Time.utc(2013,4,14,20,24,0)
      utc_stale_at = Time.utc(2013,4,14,21,24,0)

      expect( response.current.observed_at.utc ).to eq utc_observed_at
      expect( response.current.stale_at.utc ).to eq utc_stale_at
      expect( response.timezone.to_s ).to eq 'PDT'
    end

    it "parses the timezones correctly for forecasted weather" do
      payload = Barometer::Utils::Payload.new({
        "item" => {
          "pubDate" => "Sun, 14 Apr 2013 1:24 pm PDT",
          "forecast" => [
            {
              "@date" => "14 Apr 2013"
            }
          ]
        }
      })
      response = Yahoo::Response.new.parse(payload)

      utc_starts_at = Time.utc(2013,4,14,7,0,0)
      utc_ends_at = Time.utc(2013,4,15,6,59,59)

      expect( response.forecast[0].starts_at.utc ).to eq utc_starts_at
      expect( response.forecast[0].ends_at.utc ).to eq utc_ends_at
    end

    it "parses sun timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        "item" => {
          "pubDate" => "Sun, 14 Apr 2013 1:24 pm PDT",
          "forecast" => [
            {
              "@date" => "15 Apr 2013"
            }
          ]
        },
        "astronomy" => {
          "@sunrise" => "6:44 am",
          "@sunset" => "5:32 pm"
        }
      })
      response = Yahoo::Response.new.parse(payload)

      utc_current_sun_rise = Time.utc(2013,4,14,13,44,0)
      utc_current_sun_set = Time.utc(2013,4,15,0,32,0)
      utc_forecast_sun_rise = Time.utc(2013,4,15,13,44,0)
      utc_forecast_sun_set = Time.utc(2013,4,16,0,32,0)

      expect( response.current.sun.rise.utc ).to eq utc_current_sun_rise
      expect( response.current.sun.set.utc ).to eq utc_current_sun_set
      expect( response.forecast[0].sun.rise ).to eq utc_forecast_sun_rise
      expect( response.forecast[0].sun.set.utc ).to eq utc_forecast_sun_set
    end
  end
end
