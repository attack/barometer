require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Service::Geocode, :vcr => {
  :cassette_name => "WebService::Geocode"
} do
  describe ".fetch" do
    it "returns a Geo object" do
      query = Barometer::Query.new("90210")
      Barometer::Query::Service::Geocode.fetch(query).is_a?(Barometer::Data::Geo).should be_true
    end
  end
end
