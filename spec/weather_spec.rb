require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Weather" do
  
  describe "when initialized" do
    
    before(:each) do
      @weather = Barometer::Weather.new
    end

    it "responds to measurements (and sets default value)" do
      @weather.measurements.should == []
    end

    it "responds to current" do
      @weather.respond_to?("current").should be_true
    end

    it "responds to forecast" do
      @weather.respond_to?("forecast").should be_true
    end

    it "responds to today" do
      @weather.respond_to?("today").should be_true
    end

    it "responds to tommorrow" do
      @weather.respond_to?("tomorrow").should be_true
    end

    it "responds to for" do
      @weather.respond_to?("for").should be_true
    end

  end
  
  describe "with measurements" do
    
    before(:each) do
      @weather = Barometer::Weather.new
      @wunderground = Barometer::Measurement.new(:wunderground)
      @wunderground.stub!(:success).and_return(true)
      @wunderground.stub!(:success?).and_return(true)
      @yahoo = Barometer::Measurement.new(:yahoo)
      @yahoo.stub!(:success).and_return(true)
      @yahoo.stub!(:success?).and_return(true)
      @google = Barometer::Measurement.new(:google)
      @weather.measurements << @wunderground
      @weather.measurements << @yahoo
      @weather.measurements << @google
    end
    
    it "retrieves a source measurement" do
      lambda { @weather.source(1) }.should raise_error(ArgumentError)
      lambda { @weather.source("valid") }.should_not raise_error(ArgumentError)
      lambda { @weather.source(:valid) }.should_not raise_error(ArgumentError)
      @weather.source(:does_not_exist).should be_nil
      @weather.source(:wunderground).should == @wunderground
    end
    
    it "lists the sources of measurements (that were successful)" do
      sources = @weather.sources
      sources.should_not be_nil
      @wunderground.success?.should be_true
      sources.include?(:wunderground).should be_true
      @yahoo.success?.should be_true
      sources.include?(:yahoo).should be_true
      @google.success?.should be_false
      sources.include?(:google).should be_false
    end
    
    it "returns the default source" do
      @weather.default.should == @wunderground
    end
    
  end
  
  describe "when calculating averages" do
    
    before(:each) do
      @weather = Barometer::Weather.new
      @wunderground = Barometer::Measurement.new(:wunderground)
      @wunderground.current = Barometer::Measurement::Result.new
      @wunderground.stub!(:success).and_return(true)
      @wunderground.stub!(:success?).and_return(true)
      @yahoo = Barometer::Measurement.new(:yahoo)
      @yahoo.current = Barometer::Measurement::Result.new
      @yahoo.stub!(:success).and_return(true)
      @yahoo.stub!(:success?).and_return(true)
      @google = Barometer::Measurement.new(:google)
      @weather.measurements << @wunderground
      @weather.measurements << @yahoo
      @weather.measurements << @google
    end
    
    it "doesn't include nil values" do
      @weather.source(:wunderground).current.temperature = Data::Temperature.new
      @weather.source(:wunderground).current.temperature.c = 10
      
      @weather.temperature.c.should == 10
      
      @weather.source(:yahoo).current.temperature = Data::Temperature.new
      @weather.source(:yahoo).current.temperature.c = nil
      
      @weather.temperature.c.should == 10
    end
    
    it "respects the measurement weight" do
      @weather.source(:wunderground).current.temperature = Data::Temperature.new
      @weather.source(:wunderground).current.temperature.c = 10
      @weather.source(:yahoo).current.temperature = Data::Temperature.new
      @weather.source(:yahoo).current.temperature.c = 4
      
      @weather.measurements.first.weight = 2
      
      @weather.temperature.c.should == 8
    end
    
    describe "for temperature" do
      
      before(:each) do
        @weather.source(:wunderground).current.temperature = Data::Temperature.new
        @weather.source(:wunderground).current.temperature.c = 10
        @weather.source(:yahoo).current.temperature = Data::Temperature.new
        @weather.source(:yahoo).current.temperature.c = 6
      end

      it "returns averages" do
        @weather.temperature.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.temperature(false).c.should == 10
      end
      
    end
    
    describe "for wind" do
      
      before(:each) do
        @weather.source(:wunderground).current.wind = Data::Speed.new
        @weather.source(:wunderground).current.wind.kph = 10
        @weather.source(:yahoo).current.wind = Data::Speed.new
        @weather.source(:yahoo).current.wind.kph = 6
      end

      it "returns averages" do
        @weather.wind.kph.should == 8
      end
      
      it "returns default when disabled" do
        @weather.wind(false).kph.should == 10
      end
      
    end
    
    describe "for humidity" do
      
      before(:each) do
        @weather.source(:wunderground).current.humidity = 10
        @weather.source(:yahoo).current.humidity = 6
      end

      it "returns averages" do
        @weather.humidity.should == 8
      end
      
      it "returns default when disabled" do
        @weather.humidity(false).should == 10
      end
      
    end
    
    describe "for pressure" do
      
      before(:each) do
        @weather.source(:wunderground).current.pressure = Data::Pressure.new
        @weather.source(:wunderground).current.pressure.mb = 10
        @weather.source(:yahoo).current.pressure = Data::Pressure.new
        @weather.source(:yahoo).current.pressure.mb = 6
      end

      it "returns averages" do
        @weather.pressure.mb.should == 8
      end
      
      it "returns default when disabled" do
        @weather.pressure(false).mb.should == 10
      end
      
    end
    
    describe "for dew_point" do
      
      before(:each) do
        @weather.source(:wunderground).current.dew_point = Data::Temperature.new
        @weather.source(:wunderground).current.dew_point.c = 10
        @weather.source(:yahoo).current.dew_point = Data::Temperature.new
        @weather.source(:yahoo).current.dew_point.c = 6
      end

      it "returns averages" do
        @weather.dew_point.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.dew_point(false).c.should == 10
      end
      
    end
    
    describe "for heat_index" do
      
      before(:each) do
        @weather.source(:wunderground).current.heat_index = Data::Temperature.new
        @weather.source(:wunderground).current.heat_index.c = 10
        @weather.source(:yahoo).current.heat_index = Data::Temperature.new
        @weather.source(:yahoo).current.heat_index.c = 6
      end

      it "returns averages" do
        @weather.heat_index.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.heat_index(false).c.should == 10
      end
      
    end
    
    describe "for wind_chill" do
      
      before(:each) do
        @weather.source(:wunderground).current.wind_chill = Data::Temperature.new
        @weather.source(:wunderground).current.wind_chill.c = 10
        @weather.source(:yahoo).current.wind_chill = Data::Temperature.new
        @weather.source(:yahoo).current.wind_chill.c = 6
      end

      it "returns averages" do
        @weather.wind_chill.c.should == 8
      end
      
      it "returns default when disabled" do
        @weather.wind_chill(false).c.should == 10
      end
      
    end
    
    describe "for visibility" do
      
      before(:each) do
        @weather.source(:wunderground).current.visibility = Data::Distance.new
        @weather.source(:wunderground).current.visibility.km = 10
        @weather.source(:yahoo).current.visibility = Data::Distance.new
        @weather.source(:yahoo).current.visibility.km = 6
      end

      it "returns averages" do
        @weather.visibility.km.should == 8
      end
      
      it "returns default when disabled" do
        @weather.visibility(false).km.should == 10
      end
      
    end
    
  end
  
  describe "when answering the simple questions," do
    
    before(:each) do
      @weather = Barometer::Weather.new
      @now = Data::LocalDateTime.parse("2:05 pm")
    end
    
    describe "windy?" do
      
      # it "requires time as a Data::LocalTime object" do
      #   #lambda { @weather.windy?(1,"a") }.should raise_error(ArgumentError)
      #   lambda { @weather.windy?(1,@now) }.should_not raise_error(ArgumentError)
      # end
      
      it "requires threshold as a number" do
        lambda { @weather.windy?(@now,"a") }.should raise_error(ArgumentError)
        lambda { @weather.windy?(@now,1) }.should_not raise_error(ArgumentError)
        lambda { @weather.windy?(@now,1.1) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.windy?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:windy?).and_return(true) }
        @weather.windy?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:windy?).and_return(false) }
        @weather.windy?.should be_false
      end
      
    end
    
    describe "wet?" do
      
      it "requires threshold as a number" do
        lambda { @weather.wet?(@now,"a") }.should raise_error(ArgumentError)
        lambda { @weather.wet?(@now,1) }.should_not raise_error(ArgumentError)
        lambda { @weather.wet?(@now,1.1) }.should_not raise_error(ArgumentError)
      end
      
      # it "requires time as a Data::LocalTime object" do
      #   #lambda { @weather.wet?(1,"a") }.should raise_error(ArgumentError)
      #   lambda { @weather.wet?(1,@now) }.should_not raise_error(ArgumentError)
      # end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.wet?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:wet?).and_return(true) }
        @weather.wet?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:wet?).and_return(false) }
        @weather.wet?.should be_false
      end
      
    end
    
    describe "day? and night?" do
      
      it "requires time as a Data::LocalTime object" do
        #lambda { @weather.day?("a") }.should raise_error(ArgumentError)
        lambda { @weather.day?(@now) }.should_not raise_error(ArgumentError)
      end
      
      it "requires time as a Data::LocalTime object" do
        #lambda { @weather.night?("a") }.should raise_error(ArgumentError)
        lambda { @weather.night?(@now) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.day?.should be_nil
        @weather.night?.should be_nil
      end
      
      it "returns true if a measurement returns true (night is opposite)" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:day?).and_return(true) }
        @weather.day?.should be_true
        @weather.night?.should be_false
      end

      it "returns false if a measurement returns false (night is opposite)" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:day?).and_return(false) }
        @weather.day?.should be_false
        @weather.night?.should be_true
      end
      
    end
    
    describe "sunny?" do
      
      it "requires time as a Data::LocalTime object" do
        #lambda { @weather.sunny?("a") }.should raise_error(ArgumentError)
        lambda { @weather.sunny?(@now) }.should_not raise_error(ArgumentError)
      end
      
      it "returns nil when no measurements" do
        @weather.measurements.should be_empty
        @weather.sunny?.should be_nil
      end
      
      it "returns true if a measurement returns true" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:day?).and_return(true) }
        @weather.measurements.each { |m| m.stub!(:sunny?).and_return(true) }
        @weather.sunny?.should be_true
      end

      it "returns false if a measurement returns false" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:day?).and_return(true) }
        @weather.measurements.each { |m| m.stub!(:sunny?).and_return(false) }
        @weather.sunny?.should be_false
      end
      
      it "returns false if night time" do
        wunderground = Barometer::Measurement.new(:wunderground)
        wunderground.stub!(:success).and_return(true)
        wunderground.stub!(:success?).and_return(true)
        @weather.measurements << wunderground
        @weather.measurements.each { |m| m.stub!(:sunny?).and_return(true) }
        @weather.measurements.each { |m| m.stub!(:day?).and_return(false) }
        @weather.sunny?.should be_false
      end

    end
    
  end
  
end