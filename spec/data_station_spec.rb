require 'spec_helper'

describe "Station" do
  
  describe "when initialized" do
    
    before(:each) do
      @station = Barometer::Station.new
    end
    
    it "responds to id" do
      @station.id.should be_nil
    end
    
    it "responds to name" do
      @station.name.should be_nil
    end
    
    it "responds to city" do
      @station.city.should be_nil
    end
    
    it "responds to state_name" do
      @station.state_name.should be_nil
    end
    
    it "responds to state_code" do
      @station.state_code.should be_nil
    end
    
    it "responds to country_code" do
      @station.country_code.should be_nil
    end
    
    it "responds to zip_code" do
      @station.zip_code.should be_nil
    end
    
    it "responds to latitude" do
      @station.latitude.should be_nil
    end
    
    it "responds to longitude" do
      @station.longitude.should be_nil
    end
    
  end
  
end