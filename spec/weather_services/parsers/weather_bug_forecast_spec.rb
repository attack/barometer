require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WeatherBugForecast do
  let(:measurement) { Barometer::Measurement.new }
  let(:query) { double(:query, :geo => nil) }

  it "parses the timezones correctly" do
    measurement.timezone = 'PDT'

    payload = Barometer::Payload.new({
      "@date" => "4/13/2013 10:23:00 AM",
      "forecast" => [{"high" => "13"}]
    })
    parser = Barometer::Parser::WeatherBugForecast.new(measurement, query)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,4,13,7,0,0)
    utc_ends_at = Time.utc(2013,4,14,6,59,59)

    measurement.forecast[0].starts_at.utc.should == utc_starts_at
    measurement.forecast[0].ends_at.utc.should == utc_ends_at
  end
end
