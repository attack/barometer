require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WundergroundCurrent do
  let(:response) { Barometer::Response.new }

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
    parser = Barometer::Parser::WundergroundForecast.new(response)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,5,19,5,46,0)
    utc_ends_at = Time.utc(2013,5,20,5,45,59)

    response.forecast[0].starts_at.utc.should == utc_starts_at
    response.forecast[0].ends_at.utc.should == utc_ends_at
    response.timezone.full.should == 'America/Los_Angeles'
  end

  it "parses sun timezones correctly" do
    response.current.observed_at = Barometer::Utils::Time.parse("May 18, 10:46 AM PDT")
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
    parser = Barometer::Parser::WundergroundForecast.new(response)
    parser.parse(payload)

    utc_current_sun_rise = Time.utc(2013,5,18,14,59,0)
    utc_current_sun_set = Time.utc(2013,5,19,0,42,0)
    utc_forecast_sun_rise = Time.utc(2013,5,19,14,59,0)
    utc_forecast_sun_set = Time.utc(2013,5,20,0,42,0)

    response.current.sun.rise.utc.should == utc_current_sun_rise
    response.current.sun.set.utc.should == utc_current_sun_set
    response.forecast[0].sun.rise.utc.should == utc_forecast_sun_rise
    response.forecast[0].sun.set.utc.should == utc_forecast_sun_set
  end
end
