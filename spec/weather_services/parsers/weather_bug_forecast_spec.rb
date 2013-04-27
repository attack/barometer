require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WeatherBugForecast do
  let(:response) { Barometer::Response.new }
  let(:query) { double(:query, :geo => nil) }

  it "parses the timezones correctly" do
    response.timezone = 'PDT'

    payload = Barometer::Utils::Payload.new({
      "@date" => "4/13/2013 10:23:00 AM",
      "forecast" => [{"high" => "13"}]
    })
    parser = Barometer::Parser::WeatherBugForecast.new(response, query)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,4,13,7,0,0)
    utc_ends_at = Time.utc(2013,4,14,6,59,59)

    response.forecast[0].starts_at.utc.should == utc_starts_at
    response.forecast[0].ends_at.utc.should == utc_ends_at
  end
end
