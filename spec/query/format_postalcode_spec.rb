require 'spec_helper'

describe "Query::Postalcode" do
  
  describe "and class methods" do
    
    it "returns a format" do
      Barometer::Query::Postalcode.format.should == :postalcode
    end
    
    it "returns a country" do
      Barometer::Query::Postalcode.country_code.should == "CA"
      Barometer::Query::Postalcode.country_code("ignored").should == "CA"
    end
    
    it "returns a regex" do
      Barometer::Query::Postalcode.regex.should_not be_nil
      Barometer::Query::Postalcode.regex.is_a?(Regexp).should be_true
    end
    
    describe "is?," do
      
      before(:each) do
        @valid = "T5B 4M9"
        @invalid = "90210"
      end
      
      it "recognizes a valid format" do
        Barometer::Query::Postalcode.is?(@valid).should be_true
      end
      
      it "recognizes non-valid format" do
        Barometer::Query::Postalcode.is?(@invalid).should be_false
      end
      
    end
  
    it "stubs to" do
      Barometer::Query::Postalcode.to.should be_nil
    end

  end
  
end