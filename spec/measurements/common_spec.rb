require 'spec_helper'

describe "Common Measurement" do
  
  describe "when initialized" do
    
    before(:each) do
      @common = Measurement::Common.new
    end
    
    it "responds to humidity" do
      @common.humidity.should be_nil
    end
    
    it "responds to icon" do
      @common.icon.should be_nil
    end
    
    it "responds to condition" do
      @common.condition.should be_nil
    end
    
    it "responds to wind" do
      @common.wind.should be_nil
    end
    
    it "responds to sun" do
      @common.sun.should be_nil
    end
    
    it "responds to metric" do
      @common.metric.should be_true
    end
    
    it "responds to metric?" do
      @common.metric?.should be_true
      @common.metric = false
      @common.metric?.should be_false
    end
    
  end
  
  describe "when writing data" do
    
    before(:each) do
      @common = Measurement::Common.new
    end
    
    it "only accepts Fixnum or Float for humidity" do
      invalid_data = "invalid"
      invalid_data.class.should_not == Fixnum
      invalid_data.class.should_not == Float
      lambda { @common.humidity = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = 1.to_i
      valid_data.class.should == Fixnum
      lambda { @common.humidity = valid_data }.should_not raise_error(ArgumentError)
      
      valid_data = 1.0.to_f
      valid_data.class.should == Float
      lambda { @common.humidity = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for icon" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @common.icon = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @common.icon = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts String for condition" do
      invalid_data = 1
      invalid_data.class.should_not == String
      lambda { @common.condition = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = "valid"
      valid_data.class.should == String
      lambda { @common.condition = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Speed for wind" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Speed
      lambda { @common.wind = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Speed.new
      valid_data.class.should == Data::Speed
      lambda { @common.wind = valid_data }.should_not raise_error(ArgumentError)
    end
    
    it "only accepts Data::Sun for sun" do
      invalid_data = 1
      invalid_data.class.should_not == Data::Sun
      lambda { @common.sun = invalid_data }.should raise_error(ArgumentError)
      
      valid_data = Data::Sun.new
      valid_data.class.should == Data::Sun
      lambda { @common.sun = valid_data }.should_not raise_error(ArgumentError)
    end
    
  end
  
  describe "method missing" do
    
    before(:each) do
      @common = Measurement::Common.new
    end
    
    it "responds to method + ?" do
      valid_method = "humidity"
      @common.respond_to?(valid_method).should be_true
      lambda { @common.send(valid_method + "?") }.should_not raise_error(NoMethodError)
    end
    
    it "ignores non_method + ?" do
      invalid_method = "humid"
      @common.respond_to?(invalid_method).should be_false
      lambda { @common.send(invalid_method + "?") }.should raise_error(NoMethodError)
    end
    
    it "returns true if set" do
      @common.humidity = 10
      @common.humidity.should_not be_nil
      @common.humidity?.should be_true
    end
    
    it "returns false if not set" do
      @common.humidity.should be_nil
      @common.humidity?.should be_false
    end
    
  end
  
  describe "answer simple questions, like" do
    
    before(:each) do
      @common = Measurement::Common.new
    end
    
    describe "windy?" do
      
      before(:each) do
        @wind = Data::Speed.new
        @wind << 11
      end

      it "requires real threshold number (or nil)" do
        lambda { @common.windy?("invalid") }.should raise_error(ArgumentError)
        lambda { @common.windy? }.should_not raise_error(ArgumentError)
        lambda { @common.windy?(10) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no wind" do
        @common.wind?.should be_false
        @common.windy?.should be_nil
        @common.wind = @wind
        @common.wind?.should be_true
        @common.windy?.should_not be_nil
      end
      
      it "return true when current wind over threshold" do
        @common.wind = @wind
        @common.windy?.should be_true
        @common.windy?(10).should be_true
      end
      
      it "return false when current wind under threshold" do
        @common.wind = @wind
        @common.windy?(15).should be_false
      end
      
    end
    
    describe "day?" do
      
      before(:each) do
        @early_time = Data::LocalTime.parse("6:00 am")
        @mid_time = Data::LocalTime.parse("11:00 am")
        @late_time = Data::LocalTime.parse("8:00 pm")
        @sun = Data::Sun.new(@early_time, @late_time)
        
      end

      it "requires Data::LocalTime object" do
        @common.sun = @sun
        lambda { @common.day?("invalid") }.should raise_error(ArgumentError)
        lambda { @common.day? }.should raise_error(ArgumentError)
        lambda { @common.day?(@mid_time) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no sun" do
        @common.sun?.should be_false
        @common.day?(@mid_time).should be_nil
        @common.sun = @sun
        @common.sun?.should be_true
        @common.day?(@mid_time).should_not be_nil
      end
      
      it "return true when time between rise and set" do
        @common.sun = @sun
        @common.day?(@mid_time).should be_true
      end
      
      it "return false when time before rise or after set" do
        sun = Data::Sun.new(@mid_time, @late_time)
        @common.sun = sun
        @common.day?(@early_time).should be_false
        
        sun = Data::Sun.new(@early_time, @mid_time)
        @common.sun = sun
        @common.day?(@late_time).should be_false
      end
      
    end
    
    describe "wet?" do
      
      describe "wet_by_humidity?" do
        
        it "requires real threshold number (or nil)" do
          lambda { @common.send("_wet_by_humidity?","invalid") }.should raise_error(ArgumentError)
          lambda { @common.send("_wet_by_humidity?") }.should_not raise_error(ArgumentError)
          lambda { @common.send("_wet_by_humidity?",99) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no humidity" do
          @common.humidity?.should be_false
          @common.send("_wet_by_humidity?").should be_nil
          @common.wet?(nil,99).should be_nil
          @common.humidity = 100
          @common.humidity?.should be_true
          @common.send("_wet_by_humidity?").should_not be_nil
          @common.wet?(nil,99).should_not be_nil
        end

        it "return true when current humidity over threshold" do
          @common.humidity = 100
          @common.send("_wet_by_humidity?").should be_true
          @common.send("_wet_by_humidity?",99).should be_true
          @common.wet?(nil,99).should be_true
        end

        it "return false when current humidity under threshold" do
          @common.humidity = 98
          @common.send("_wet_by_humidity?",99).should be_false
          @common.wet?(nil,99).should be_false
        end

      end
      
      describe "wet_by_icon?" do
        
        before(:each) do
          @wet_icons = %w(rain thunderstorm)
        end

        it "requires Array (or nil)" do
          lambda { @common.send("_wet_by_icon?","invalid") }.should raise_error(ArgumentError)
          lambda { @common.send("_wet_by_icon?") }.should_not raise_error(ArgumentError)
          lambda { @common.send("_wet_by_icon?",@wet_icons) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no icon or Array" do
          @common.icon?.should be_false
          @common.send("_wet_by_icon?",@wet_icons).should be_nil
          @common.wet?(@wet_icons).should be_nil
          @common.icon = "rain"
          @common.icon?.should be_true
          @common.send("_wet_by_icon?").should be_nil
          @common.send("_wet_by_icon?",@wet_icons).should_not be_nil
          @common.wet?(@wet_icons).should_not be_nil
        end

        it "return true when current icon indicates wet" do
          @common.icon = "rain"
          @common.send("_wet_by_icon?",@wet_icons).should be_true
          @common.wet?(@wet_icons).should be_true
        end

        it "return false when current icon does NOT indicate wet" do
          @common.icon = "sun"
          @common.send("_wet_by_icon?",@wet_icons).should be_false
          @common.wet?(@wet_icons).should be_false
        end
        
      end
      
    end
    
    describe "sunny?" do
      
      describe "sunny_by_icon?" do
        
        before(:each) do
          @sunny_icons = %w(sunny clear)
          @early_time = Data::LocalTime.parse("6:00 am")
          @mid_time = Data::LocalTime.parse("11:00 am")
          @late_time = Data::LocalTime.parse("8:00 pm")
          @sun = Data::Sun.new(@early_time, @late_time)
          
          @common.sun = @sun
        end

        it "requires Array (or nil)" do
          lambda { @common.send("_sunny_by_icon?","invalid") }.should raise_error(ArgumentError)
          lambda { @common.send("_sunny_by_icon?") }.should_not raise_error(ArgumentError)
          lambda { @common.send("_sunny_by_icon?",@sunny_icons) }.should_not raise_error(ArgumentError)
        end

        it "returns nil when no icon or Array" do
          @common.icon?.should be_false
          @common.send("_sunny_by_icon?",@sunny_icons).should be_nil
          @common.sunny?(@mid_time,@sunny_icons).should be_nil
          @common.icon = "sunny"
          @common.icon?.should be_true
          @common.send("_sunny_by_icon?").should be_nil
          @common.send("_sunny_by_icon?",@sunny_icons).should_not be_nil
          @common.sun?(@mid_time,@sunny_icons).should_not be_nil
        end

        it "returns true when current icon indicates sunny" do
          @common.icon = "sunny"
          @common.send("_sunny_by_icon?",@sunny_icons).should be_true
          @common.sunny?(@mid_time,@sunny_icons).should be_true
        end

        it "returns false when current icon does NOT indicate sunny" do
          @common.icon = "rain"
          @common.send("_sunny_by_icon?",@sunny_icons).should be_false
          @common.sunny?(@mid_time,@sunny_icons).should be_false
        end
        
        it "returns false when night" do
          @common.icon = "sunny"
          @common.send("_sunny_by_icon?",@sunny_icons).should be_true
          @common.sunny?(@mid_time,@sunny_icons).should be_true
          
          @sun = Data::Sun.new(@mid_time, @late_time)
          @common.sun = @sun
          @common.sunny?(@early_time,@sunny_icons).should be_false
        end
        
      end
      
    end
    
  end
  
end