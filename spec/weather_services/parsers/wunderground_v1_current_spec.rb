require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Barometer::Parser
  describe WundergroundV1Current do
    let(:response) { Barometer::Response.new(build_query) }

    it "parses the timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        "local_time" => "May 18, 10:46 AM PDT"
      })
      parser = WundergroundV1Current.new(response)
      parser.parse(payload)

      utc_observed_at = Time.utc(2013,5,18,17,46,0)
      utc_stale_at = Time.utc(2013,5,18,18,0,0)

      response.current.observed_at.utc.should == utc_observed_at
      response.current.stale_at.utc.should == utc_stale_at
      response.timezone.code.should == 'PDT'
    end
  end
end
