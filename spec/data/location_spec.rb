require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Location" do
  
  describe "when initialized" do
    
    before(:each) do
      @location = Data::Location.new
    end
    
    it "responds to id" do
      @location.id.should be_nil
    end
    
    it "responds to name" do
      @location.name.should be_nil
    end
    
    it "responds to city" do
      @location.city.should be_nil
    end
    
    it "responds to state_name" do
      @location.state_name.should be_nil
    end
    
    it "responds to state_code" do
      @location.state_code.should be_nil
    end
    
    it "responds to country" do
      @location.country.should be_nil
    end
    
    it "responds to country_code" do
      @location.country_code.should be_nil
    end
    
    it "responds to zip_code" do
      @location.zip_code.should be_nil
    end
    
    it "responds to latitude" do
      @location.latitude.should be_nil
    end
    
    it "responds to longitude" do
      @location.longitude.should be_nil
    end
    
    it "responds to coordinates" do
      @location.longitude = "99.99"
      @location.latitude = "88.88"
      @location.coordinates.should == [@location.latitude, @location.longitude].join(',')
    end
    
    it "should print a string" do
      @location = Data::Location.new
      @location.to_s.should == ""
      @location.name = "name"
      @location.to_s.should == "name"
      @location.city = "city"
      @location.to_s.should == "name, city"
      @location.country_code = "code"
      @location.to_s.should == "name, city, code"
    end

  end
  
end