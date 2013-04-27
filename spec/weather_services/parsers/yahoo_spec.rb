require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::Yahoo do
  let(:measurement) { Barometer::Measurement.new }
  let(:query) { double(:query, :geo => nil) }

  it "parses the timezones correctly for current weather" do
    payload = Barometer::Payload.new({
      "item" => {
        "pubDate" => "Sun, 14 Apr 2013 1:24 pm PDT"
      }
    })
    parser = Barometer::Parser::Yahoo.new(measurement, query)
    parser.parse(payload)

    utc_observed_at = Time.utc(2013,4,14,20,24,0)
    utc_stale_at = Time.utc(2013,4,14,21,24,0)

    measurement.current.observed_at.utc.should == utc_observed_at
    measurement.current.stale_at.utc.should == utc_stale_at
    measurement.timezone.code.should == 'PDT'
  end

  it "parses the timezones correctly for forecasted weather" do
    payload = Barometer::Payload.new({
      "item" => {
        "pubDate" => "Sun, 14 Apr 2013 1:24 pm PDT",
        "forecast" => [
          {
            "@date" => "14 Apr 2013"
          }
        ]
      }
    })
    parser = Barometer::Parser::Yahoo.new(measurement, query)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,4,14,7,0,0)
    utc_ends_at = Time.utc(2013,4,15,6,59,59)

    measurement.forecast[0].starts_at.utc.should == utc_starts_at
    measurement.forecast[0].ends_at.utc.should == utc_ends_at
  end

  it "parses sun timezones correctly" do
    payload = Barometer::Payload.new({
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
    parser = Barometer::Parser::Yahoo.new(measurement, query)
    parser.parse(payload)

    utc_current_sun_rise = Time.utc(2013,4,14,13,44,0)
    utc_current_sun_set = Time.utc(2013,4,15,0,32,0)
    utc_forecast_sun_rise = Time.utc(2013,4,15,13,44,0)
    utc_forecast_sun_set = Time.utc(2013,4,16,0,32,0)

    measurement.current.sun.rise.utc.should == utc_current_sun_rise
    measurement.current.sun.set.utc.should == utc_current_sun_set
    measurement.forecast[0].sun.rise.utc.should == utc_forecast_sun_rise
    measurement.forecast[0].sun.set.utc.should == utc_forecast_sun_set
  end
end
