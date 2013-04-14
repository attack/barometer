require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService::Geocode, :vcr => {
  :cassette_name => "WebService::Geocode"
} do
  before(:each) do
    @zipcode = "90210"
  end

  describe "and the class methods" do
    describe "fetch," do
      it "returns a Geo object" do
        query = Barometer::Query.new(@zipcode)
        Barometer::WebService::Geocode.fetch(query).is_a?(Barometer::Data::Geo).should be_true
      end
    end
  end
end
