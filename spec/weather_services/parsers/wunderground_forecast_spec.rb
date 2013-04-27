require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WundergroundCurrent do
  let(:measurement) { Barometer::Measurement.new }
  let(:query) { double(:query) }

  it "parses the timezones correctly" do
    payload = Barometer::Payload.new({
      "simpleforecast" => { "forecastday" => [
        {
          "date" => {
            "tz_long" => 'America/Los_Angeles',
            "pretty" => '10:46 PM PDT on May 18, 2013'
          }
        }
      ]}
    })
    parser = Barometer::Parser::WundergroundForecast.new(measurement, query)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,5,19,5,46,0)
    utc_ends_at = Time.utc(2013,5,20,5,45,59)

    measurement.forecast[0].starts_at.utc.should == utc_starts_at
    measurement.forecast[0].ends_at.utc.should == utc_ends_at
    measurement.timezone.full.should == 'America/Los_Angeles'
  end

  it "parses sun timezones correctly" do
    measurement.current.observed_at = Barometer::Utils::Time.parse("May 18, 10:46 AM PDT")
    payload = Barometer::Payload.new({
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
    parser = Barometer::Parser::WundergroundForecast.new(measurement, query)
    parser.parse(payload)

    utc_current_sun_rise = Time.utc(2013,5,18,14,59,0)
    utc_current_sun_set = Time.utc(2013,5,19,0,42,0)
    utc_forecast_sun_rise = Time.utc(2013,5,19,14,59,0)
    utc_forecast_sun_set = Time.utc(2013,5,20,0,42,0)

    measurement.current.sun.rise.utc.should == utc_current_sun_rise
    measurement.current.sun.set.utc.should == utc_current_sun_set
    measurement.forecast[0].sun.rise.utc.should == utc_forecast_sun_rise
    measurement.forecast[0].sun.set.utc.should == utc_forecast_sun_set
  end
end
