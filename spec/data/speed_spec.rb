require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Speed" do
  
  describe "when initialized" do
    
    it "defines METRIC_UNITS" do
      Data::Speed.const_defined?("METRIC_UNITS").should be_true
      Data::Speed::METRIC_UNITS.should == "kph"
    end
    
    it "defines IMPERIAL_UNITS" do
      Data::Speed.const_defined?("IMPERIAL_UNITS").should be_true
      Data::Speed::IMPERIAL_UNITS.should == "mph"
    end
    
    before(:each) do
      @speed = Data::Speed.new
    end
    
    it "responds to kilometers" do
      @speed.kilometers.should be_nil
    end
    
    it "responds to miles" do
      @speed.miles.should be_nil
    end
    
    it "responds to degrees" do
      @speed.degrees.should be_nil
    end
    
    it "responds to direction" do
      @speed.direction.should be_nil
    end
    
    it "responds to metric_default" do
      lambda { @speed.metric_default = 5 }.should_not raise_error(NotImplementedError)
    end
    
    it "responds to imperial_default" do
      lambda { @speed.imperial_default = 5 }.should_not raise_error(NotImplementedError)
    end
    
    it "responds to nil?" do
      @speed.nil?.should be_true
      @speed.kph = 5
      @speed.nil?.should be_false
    end
    
  end
  
  describe "conversion" do
    
    # For all conversions
    # 16.09 km/h = 10.0 mph
    before(:each) do
      @m = 10.0
      @km = 16.09
    end
    
    it "requires a value, that is either Integer or Float" do
      Data::Speed.km_to_m(nil).should be_nil
      Data::Speed.m_to_km(nil).should be_nil
      
      not_float_or_integer = "string"
      Data::Speed.km_to_m(not_float_or_integer).should be_nil
      Data::Speed.m_to_km(not_float_or_integer).should be_nil
    end
    
    it "converts km/h to mph" do
      # to get equality, we need to tone down the precision
      ((Data::Speed.km_to_m(@km)*10).round/10.0).should == @m
    end
    
    it "converts mph to km/h" do
      Data::Speed.m_to_km(@m).should == @km
    end
  
  end
  
  describe "updating" do
    
    before(:each) do
      @speed = Data::Speed.new
      @m = 10.0
      @km = 16.09
    end
    
    it "nils M if new KM converts to a M that changes more then 1 unit" do
      @speed.miles = (@m + 1.1)
      @speed.update_miles(@km)
      @speed.miles.should be_nil
    end
    
    it "doesn't update M if new KM converts to a M that does not change more then 1 unit" do
      @speed.miles = (@m + 0.9)
      @speed.update_miles(@km)
      @speed.miles.should == (@m + 0.9)
    end
    
    it "doesn't set M if not already set" do
      @speed.miles.should be_nil
      @speed.kilometers.should be_nil
      @speed.update_miles(@km)
      @speed.miles.should be_nil
      @speed.kilometers.should be_nil
    end
    
    it "nils KM if new M converts to a KM that changes more then 1 unit" do
      @speed.kilometers = (@km + 1.1)
      @speed.update_kilometers(@m)
      @speed.kilometers.should be_nil
    end
    
    it "doesn't update KM if new M converts to a KM that does not change more then 1 unit" do
      @speed.kilometers = (@km + 0.9)
      @speed.update_kilometers(@m)
      @speed.kilometers.should == (@km + 0.9)
    end
    
    it "doesn't set KM if not already set" do
      @speed.miles.should be_nil
      @speed.kilometers.should be_nil
      @speed.update_kilometers(@m)
      @speed.miles.should be_nil
      @speed.kilometers.should be_nil
    end
    
  end
  
  describe "storing" do
    
    before(:each) do
      @speed = Data::Speed.new
      @m = 10.0
      @km = 16.09
    end
    
    it "doesn't update KM if nil value (or equivalent)" do
      @speed.kilometers.should be_nil
      @speed.kph = nil
      @speed.kilometers.should be_nil
      @speed.kph = "na"
      @speed.kilometers.should be_nil
    end
    
    it "stores KM and resets M" do
      @speed.kilometers.should be_nil
      @speed.miles = (@m + 1.1)
      @speed.kph = @km
      @speed.kilometers.should == @km
      @speed.miles.should be_nil
    end
    
    it "doesn't update M if nil value (or equivalent)" do
      @speed.miles.should be_nil
      @speed.mph = nil
      @speed.miles.should be_nil
      @speed.mph = "na"
      @speed.miles.should be_nil
    end
    
    it "stores M, resets KM" do
      @speed.miles.should be_nil
      @speed.kilometers = (@km + 1.1)
      @speed.mph = @m
      @speed.miles.should == @m
      @speed.kilometers.should be_nil
    end
    
    it "doesn't update direction if nil value (or equivalent)" do
      @speed.direction.should be_nil
      @speed.direction = nil
      @speed.direction.should be_nil
      @speed.direction = "na"
      @speed.direction.should_not be_nil
    end
    
    it "stores direction" do
      @speed.direction.should be_nil
      @speed.direction = "SSW"
      @speed.direction.should == "SSW"
    end
    
    it "doesn't update degrees if nil value (or equivalent)" do
      @speed.degrees.should be_nil
      @speed.degrees = nil
      @speed.degrees.should be_nil
      @speed.degrees = "na"
      @speed.degrees.should be_nil
    end
    
    it "stores degrees" do
      @speed.degrees.should be_nil
      @speed.degrees = 90.0
      @speed.degrees.should == 90.0
    end
    
  end
  
  describe "retrieving" do
    
    before(:each) do
      @speed = Data::Speed.new
      @m = 10.0
      @km = 16.09
    end
    
    it "returns KM if it exists" do
      @speed.kph = @km
      @speed.kilometers.should == @km
      @speed.kph(false).should == @km
    end
    
    it "auto converts from M if KM is nil and M exists" do
      @speed.mph = @m
      @speed.miles.should == @m
      @speed.kilometers.should be_nil
      @speed.kph(false).should == @km
    end 
    
    it "allows a float to be returned for KM" do
      km = 16.12
      @speed.kph = km
      @speed.kilometers.should == km
      @speed.kph(true).should == km.to_i
      @speed.kph(false).should == km.to_f
    end
      
    it "allows only 2 decimal precision for KM" do
      km = 16.1234
      @speed.kph = km
      @speed.kilometers.should == km
      @speed.kph(false).should == 16.12
    end
    
    it "returns M if it exists" do
      @speed.mph = @m
      @speed.miles.should == @m
      @speed.mph.should == @m
    end
    
    it "auto converts from KM if M is nil and KM exists" do
      @speed.kph = @km
      @speed.kilometers.should == @km
      @speed.miles.should be_nil
      # to get equality, we need to tone down the precision
      ((@speed.mph*10).round/10.0).should == @m
    end 
    
    it "allows a float to be returned for M" do
      m = 10.12
      @speed.mph = m
      @speed.miles.should == m
      @speed.mph(true).should == m.to_i
      @speed.mph(false).should == m.to_f
    end
      
    it "allows only 2 decimal precision for M" do
      m = 10.1234
      @speed.mph = m
      @speed.miles.should == m
      @speed.mph(false).should == 10.12
    end
    
  end
  
  describe "operators" do
    
    before(:each) do
      @m = 10.0
      @km = 16.09
      @speed_low = Data::Speed.new
      @speed_low.kph = (@km - 1.0)
      @speed_high = Data::Speed.new
      @speed_high.kph = (@km + 1.0)
      @speed = Data::Speed.new
      @speed.kph = @km
      @speed_same = Data::Speed.new
      @speed_same.kph = @km
    end
    
    it "defines <=>" do
      Data::Speed.method_defined?("<=>").should be_true
      (@speed_low <=> @speed_high).should == -1
      (@speed_high <=> @speed_low).should == 1
      (@speed <=> @speed_same).should == 0
    end
    
    it "defines <" do
      Data::Speed.method_defined?("<").should be_true
      @speed_low.should < @speed_high
      @speed_high.should_not < @speed_low
      @speed.should_not < @speed_same
    end
    
    it "defines >" do
      Data::Speed.method_defined?(">").should be_true
      @speed_low.should_not > @speed_high
      @speed_high.should > @speed_low
      @speed.should_not > @speed_same
    end
    
    it "defines ==" do
      Data::Speed.method_defined?("==").should be_true
      @speed_low.should_not == @speed_high
      @speed.should == @speed_same
    end
    
    it "defines <=" do
      Data::Speed.method_defined?("<=").should be_true
      @speed_low.should <= @speed_high
      @speed_high.should_not <= @speed_low
      @speed.should <= @speed_same
    end
    
    it "defines >=" do
      Data::Speed.method_defined?(">=").should be_true
      @speed_low.should_not >= @speed_high
      @speed_high.should >= @speed_low
      @speed.should >= @speed_same
    end
    
  end
  
  describe "changing units" do
    
    before(:each) do
      @m = 10.51
      @km = ((Data::Speed.m_to_km(@m)*100).round/100.0)
      @speed = Data::Speed.new
      @speed.mph = @m
    end
    
    it "returns just the integer value (no units)" do
      @speed.metric?.should be_true
      @speed.to_i.should == @km.to_i
      
      @speed.imperial!
      @speed.metric?.should be_false
      @speed.to_i.should == @m.to_i
    end

    it "returns just the float value (no units)" do
      @speed.metric?.should be_true
      @speed.to_f.should == @km.to_f

      @speed.imperial!
      @speed.metric?.should be_false
      @speed.to_f.should == @m.to_f
    end
    
    it "returns just the integer value with units" do
      @speed.metric?.should be_true
      @speed.to_s.should == "#{@km.to_i} #{Data::Speed::METRIC_UNITS}"

      @speed.imperial!
      @speed.metric?.should be_false
      @speed.to_s.should == "#{@m.to_i} #{Data::Speed::IMPERIAL_UNITS}"
    end
    
    it "returns just the units" do
      @speed.metric?.should be_true
      @speed.units.should == Data::Speed::METRIC_UNITS

      @speed.imperial!
      @speed.metric?.should be_false
      @speed.units.should == Data::Speed::IMPERIAL_UNITS
    end

  end
  
end