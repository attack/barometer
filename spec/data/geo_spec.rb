require 'spec_helper'

describe "Data::Geo" do
  
  describe "when initialized" do
    
    before(:each) do
      @geo = Data::Geo.new
    end
    
    it "responds to query" do
      @geo.query.should be_nil
    end
    
    it "responds to latitude" do
      @geo.latitude.should be_nil
    end
    
    it "responds to longitude" do
      @geo.longitude.should be_nil
    end
    
    it "responds to country_code" do
      @geo.country_code.should be_nil
    end
    
    it "responds to locality" do
      @geo.locality.should be_nil
    end
    
    it "responds to region" do
      @geo.region.should be_nil
    end
    
    it "responds to country" do
      @geo.country.should be_nil
    end
    
    it "responds to address" do
      @geo.address.should be_nil
    end
    
    it "responds to coordinates" do
      @geo.longitude = "99.99"
      @geo.latitude = "88.88"
      @geo.coordinates.should == [@geo.latitude, @geo.longitude].join(',')
    end
    
    it "should print a string" do
      @geo = Data::Geo.new
      @geo.to_s.should == ""
      @geo.address = "address"
      @geo.to_s.should == "address"
      @geo.locality = "locality"
      @geo.to_s.should == "address, locality"
      @geo.country_code = "code"
      @geo.to_s.should == "address, locality, code"
    end
    
    it "requires Hash object" do
      lambda { Data::Geo.new(1) }.should raise_error(ArgumentError)
      lambda { Data::Geo.new(Hash.new) }.should_not raise_error(ArgumentError)
    end
    
    it "returns a Barometer::Geo object" do
      geo = Data::Geo.new(Hash.new)
      geo.is_a?(Data::Geo).should be_true
    end
    
  end
  
  describe "when converting" do
    
    before(:each) do
      @geo = Data::Geo.new
    end
    
    describe "from HTTParty" do
    
      it "accepts HTTParty::Response object" do
        location = Hash.new
        lambda { @geo.build_from_hash(1) }.should raise_error(ArgumentError)
        lambda { @geo.build_from_hash }.should_not raise_error(ArgumentError)
        lambda { @geo.build_from_hash(location) }.should_not raise_error(ArgumentError)
      end
      
    end
    
  end
  
end