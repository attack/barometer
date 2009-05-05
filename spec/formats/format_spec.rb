require 'spec_helper'

describe "Query::Format" do
  
  describe "and class methods" do
    
    describe "is?," do
      
      it "requires a String" do
        invalid = 1
        lambda { Barometer::Query::Format.is?(invalid) }.should raise_error(ArgumentError)
        
        valid = "string"
        valid.is_a?(String).should be_true
        lambda { Barometer::Query::Format.is?(valid) }.should_not raise_error(ArgumentError)
      end
      
      it "calls a stubbed undefined method" do
        lambda { Barometer::Query::Format.is?("valid") }.should raise_error(NotImplementedError)
      end 
      
    end
    
    it "stubs regex" do
      lambda { Barometer::Query::Format.regex }.should raise_error(NotImplementedError)
    end
    
    it "stubs format" do
      lambda { Barometer::Query::Format.format }.should raise_error(NotImplementedError)
    end
    
    it "stubs to" do
      Barometer::Query::Format.to.should be_nil
    end
    
    it "stubs country_code" do
      Barometer::Query::Format.country_code.should be_nil
    end
    
  end
  
end