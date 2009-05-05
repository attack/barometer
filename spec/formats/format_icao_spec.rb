require 'spec_helper'

describe "Query::Icao" do
  
  describe "and class methods" do
    
    it "returns a format" do
      Barometer::Query::Icao.format.should == :icao
    end
    
    it "returns a country" do
      Barometer::Query::Icao.country_code.should be_nil
    end
    
    it "returns a regex" do
      Barometer::Query::Icao.regex.should_not be_nil
      Barometer::Query::Icao.regex.is_a?(Regexp).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "KSFO"
        @invalid = "invalid"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::Icao.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Barometer::Query::Icao.is?(@invalid).should be_false
      end
      
    end
  
    it "stubs to" do
      Barometer::Query::Icao.to.should be_nil
    end
    
  end
  
end