require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WundergroundCurrent do
  let(:measurement) { Barometer::Measurement.new }
  let(:query) { double(:query, :geo => nil) }

  it "parses the timezones correctly" do
    payload = Barometer::Payload.new({
      "local_time" => "May 18, 10:46 AM PDT"
    })
    parser = Barometer::Parser::WundergroundCurrent.new(measurement, query)
    parser.parse(payload)

    utc_observed_at = Time.utc(2013,5,18,17,46,0)
    utc_stale_at = Time.utc(2013,5,18,18,0,0)

    measurement.current.observed_at.utc.should == utc_observed_at
    measurement.current.stale_at.utc.should == utc_stale_at
    measurement.timezone.code.should == 'PDT'
  end
end
