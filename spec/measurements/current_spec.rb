require 'spec_helper'

describe "Current Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @current = Measurement::Current.new
    end
    
    it "responds to temperature" do
      @current.temperature.should be_nil
    end
    
    it "responds to dew_point" do
      @current.dew_point.should be_nil
    end
    
    it "responds to heat_index" do
      @current.heat_index.should be_nil
    end
    
    it "responds to wind_chill" do
      @current.wind_chill.should be_nil
    end
    
    it "responds to pressure" do
      @current.pressure.should be_nil
    end
    
    it "responds to visibility" do
      @current.pressure.should be_nil
    end
    
    it "responds to current_at" do
      @current.current_at.should be_nil
    end
    
    it "responds to updated_at" do
      @current.updated_at.should be_nil
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @current = Measurement::Current.new
    end
    
    it "only accepts Data::Temperature for temperature" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.temperature = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.temperature = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for dew_point" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.dew_point = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.dew_point = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for heat_index" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.heat_index = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.heat_index = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Temperature for wind_chill" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Temperature
      lambda { @current.wind_chill = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Temperature.new
      valid_data.class.should == Data::Temperature
      lambda { @current.wind_chill = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Pressure for pressure" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Pressure
      lambda { @current.pressure = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Pressure.new
      valid_data.class.should == Data::Pressure
      lambda { @current.pressure = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Distance for visibility" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Distance
      lambda { @current.visibility = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Distance.new
      valid_data.class.should == Data::Distance
      lambda { @current.visibility = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::LocalTime || Data::LocalDateTime current_at" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalTime
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @current.current_at = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::LocalTime.new
      valid_data.class.should == Data::LocalTime
      lambda { @current.current_at = valid_data }.should_not raise_error(ArgumentError)
      
      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @current.current_at = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::LocalTime || Data::LocalDateTime current_at" do
      invalid_data = 1
      invalid_data.class.should_not == Data::LocalTime
      invalid_data.class.should_not == Data::LocalDateTime
      lambda { @current.updated_at = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::LocalTime.new
      valid_data.class.should == Data::LocalTime
      lambda { @current.updated_at = valid_data }.should_not raise_error(ArgumentError)
      
      valid_data = Data::LocalDateTime.new(2009,1,1)
      valid_data.class.should == Data::LocalDateTime
      lambda { @current.updated_at = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "answer simple questions, like" do
    
    before(:each) do
      @current = Measurement::Current.new
      @current.temperature = Data::Temperature.new
      @current.temperature << 5
      @dew_point = Data::Temperature.new
      @dew_point << 10
    end
    
    describe "wet?" do
      
      describe "wet_by_dewpoint?" do
        
        it "returns nil when no dewpoint" do
          @current.dew_point?.should be_false
          @current.send("_wet_by_dewpoint?").should be_nil
          @current.wet?.should be_nil
          @current.dew_point = @dew_point
          @current.dew_point?.should be_true
          @current.send("_wet_by_dewpoint?").should_not be_nil
          @current.wet?.should_not be_nil
        end

        it "return true when current dewpoint over temperature" do
          @current.dew_point = @dew_point
          @current.send("_wet_by_dewpoint?").should be_true
          @current.wet?.should be_true
        end

        it "return false when current dewpoint under temperature" do
          @current.temperature << 15
          @current.dew_point = @dew_point
          @current.send("_wet_by_dewpoint?").should be_false
          @current.wet?.should be_false
        end

      end
      
    end
    
  end

end