require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Query::Geocode" do
  
  before(:each) do
    @zipcode = "90210"
  end
  
  describe "and the class methods" do
    
    describe "fetch," do
      
      it "requires a Query object" do
        lambda { Barometer::WebService::Geocode.fetch }.should raise_error(ArgumentError)
        lambda { Barometer::WebService::Geocode.fetch("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Barometer::WebService::Geocode.fetch(query) }.should_not raise_error(ArgumentError)
      end
      
      it "queries (key no longer required)" do
        query = Barometer::Query.new(@zipcode)
        Barometer::WebService::Geocode.fetch(query).should_not be_nil
      end
      
      it "returns a Geo object" do
        query = Barometer::Query.new(@zipcode)
        Barometer::WebService::Geocode.fetch(query).is_a?(Data::Geo).should be_true
      end
      
    end
    
  end
  
end