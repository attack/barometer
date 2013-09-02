require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# describe Barometer::Parser::NoaaCurrent do
#   let(:response) { Barometer::Response.new }

#   it "parses the timezones correctly" do
#     payload = Barometer::Utils::Payload.new({
#       "observation_time_rfc822" => "Sun, 14 Apr 2013 10:51:00 -0700",
#       "observation_time" => "Last Updated on Apr 14 2013, 10:51 am PDT"
#     })
#     parser = Barometer::Parser::NoaaCurrent.new(response)
#     parser.parse(payload)

#     utc_observed_at = Time.utc(2013,04,14,17,51,00)
#     utc_stale_at = Time.utc(2013,04,14,18,51,00)

#     response.current.observed_at.utc.should == utc_observed_at
#     response.current.stale_at.utc.should == utc_stale_at
#     response.timezone.code.should == 'PDT'
#   end
# end
