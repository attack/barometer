require 'spec_helper'

require 'rubygems'
require 'graticule'

describe "Geo" do
  
  describe "when initialized" do
    
    before(:each) do
      @geo = Barometer::Geo.new
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
    
    it "requires Graticule::Location or Hash object" do
      location = Graticule::Location.new
      lambda { Barometer::Geo.new(1) }.should raise_error(ArgumentError)
      lambda { Barometer::Geo.new(location) }.should_not raise_error(ArgumentError)
      lambda { Barometer::Geo.new(Hash.new) }.should_not raise_error(ArgumentError)
    end
    
    it "returns a Barometer::Geo object" do
      location = Graticule::Location.new
      geo = Barometer::Geo.new(location)
      geo.is_a?(Barometer::Geo).should be_true
    end
    
  end
  
  describe "when converting" do
    
    before(:each) do
      @geo = Barometer::Geo.new
    end
    
    describe "from Graticule" do
    
      it "requires Graticule::Location object (or nil)" do
        location = Graticule::Location.new
        lambda { @geo.build_from_graticule(1) }.should raise_error(ArgumentError)
        lambda { @geo.build_from_graticule }.should_not raise_error(ArgumentError)
        lambda { @geo.build_from_graticule(location) }.should_not raise_error(ArgumentError)
      end
      
    end
    
    describe "from HTTParty" do
    
      it "accepts HTTParty::Response object" do
        location = Hash.new
        lambda { @geo.build_from_httparty(1) }.should raise_error(ArgumentError)
        lambda { @geo.build_from_httparty }.should_not raise_error(ArgumentError)
        lambda { @geo.build_from_httparty(location) }.should_not raise_error(ArgumentError)
      end
      
    end
    
  end
  
end