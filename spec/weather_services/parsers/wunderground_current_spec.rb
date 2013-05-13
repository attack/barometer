require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::WundergroundCurrent do
  let(:response) { Barometer::Response.new }

  it "parses the timezones correctly" do
    payload = Barometer::Utils::Payload.new({
      "local_time" => "May 18, 10:46 AM PDT"
    })
    parser = Barometer::Parser::WundergroundCurrent.new(response)
    parser.parse(payload)

    utc_observed_at = Time.utc(2013,5,18,17,46,0)
    utc_stale_at = Time.utc(2013,5,18,18,0,0)

    response.current.observed_at.utc.should == utc_observed_at
    response.current.stale_at.utc.should == utc_stale_at
    response.timezone.code.should == 'PDT'
  end
end
