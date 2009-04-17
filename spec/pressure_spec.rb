require 'spec_helper'

describe "Pressure" do
  
  describe "when initialized" do
    
    it "defines METRIC_UNITS" do
      Barometer::Pressure.const_defined?("METRIC_UNITS").should be_true
      Barometer::Pressure::METRIC_UNITS.should == "mb"
    end
    
    it "defines IMPERIAL_UNITS" do
      Barometer::Pressure.const_defined?("IMPERIAL_UNITS").should be_true
      Barometer::Pressure::IMPERIAL_UNITS.should == "in"
    end
    
    before(:each) do
      @pressure = Barometer::Pressure.new
    end
    
    it "responds to millibars" do
      @pressure.millibars.should be_nil
    end
    
    it "responds to inches" do
      @pressure.inches.should be_nil
    end
    
  end
  
  describe "conversion" do
    
    # For all conversions
    # 721.64 mb = 21.31 in
    before(:each) do
      @in = 21.31
      @mb = 721.64
    end
    
    it "requires a value, that is either Integer or Float" do
      Barometer::Pressure.mb_to_in(nil).should be_nil
      Barometer::Pressure.in_to_mb(nil).should be_nil
      
      not_float_or_integer = "string"
      Barometer::Pressure.mb_to_in(not_float_or_integer).should be_nil
      Barometer::Pressure.in_to_mb(not_float_or_integer).should be_nil
    end
    
    it "converts MB to IN" do
      ((Barometer::Pressure.mb_to_in(@mb)*100).round/100.0).should == @in
    end
    
    it "converts IN to MB" do
      ((Barometer::Pressure.in_to_mb(@in)*100).round/100.0).should == @mb
    end
  
  end
  
  describe "updating" do
    
    before(:each) do
      @pressure = Barometer::Pressure.new
      @in = 21.31
      @mb = 721.64
    end
    
    it "nils IN if new MB converts to a IN that changes more then 1 unit" do
      @pressure.inches = (@in + 1.1)
      @pressure.update_inches(@mb)
      @pressure.inches.should be_nil
    end
    
    it "doesn't update IN if new MB converts to a IN that does not change more then 1 unit" do
      @pressure.inches = (@in + 0.9)
      @pressure.update_inches(@mb)
      @pressure.inches.should == (@in + 0.9)
    end
    
    it "doesn't set IN if not already set" do
      @pressure.inches.should be_nil
      @pressure.millibars.should be_nil
      @pressure.update_inches(@mb)
      @pressure.inches.should be_nil
      @pressure.millibars.should be_nil
    end
    
    it "nils MB if new IN converts to a MB that changes more then 1 unit" do
      @pressure.millibars = (@mb + 1.1)
      @pressure.update_millibars(@in)
      @pressure.millibars.should be_nil
    end
    
    it "doesn't update MB if new IN converts to a MB that does not change more then 1 unit" do
      @pressure.millibars = (@mb + 0.9)
      @pressure.update_millibars(@in)
      @pressure.millibars.should == (@mb + 0.9)
    end
    
    it "doesn't set MB if not already set" do
      @pressure.inches.should be_nil
      @pressure.millibars.should be_nil
      @pressure.update_millibars(@in)
      @pressure.inches.should be_nil
      @pressure.millibars.should be_nil
    end
    
  end
  
  describe "storing" do
    
    before(:each) do
      @pressure = Barometer::Pressure.new
      @in = 21.31
      @mb = 721.64
    end
    
    it "doesn't update MB if nil value (or equivalent)" do
      @pressure.millibars.should be_nil
      @pressure.mb = nil
      @pressure.millibars.should be_nil
      @pressure.mb = "na"
      @pressure.millibars.should be_nil
    end
    
    it "stores MB and resets IN" do
      @pressure.millibars.should be_nil
      @pressure.inches = (@in + 1.1)
      @pressure.mb = @mb
      @pressure.millibars.should == @mb
      @pressure.inches.should be_nil
    end
    
    it "doesn't update IN if nil value (or equivalent)" do
      @pressure.inches.should be_nil
      @pressure.in = nil
      @pressure.inches.should be_nil
      @pressure.in = "na"
      @pressure.inches.should be_nil
    end
    
    it "stores IN and resets MB" do
      @pressure.inches.should be_nil
      @pressure.millibars = (@mb + 1.1)
      @pressure.in = @in
      @pressure.inches.should == @in
      @pressure.millibars.should be_nil
    end
    
  end
  
  describe "retrieving" do
    
    before(:each) do
      @pressure = Barometer::Pressure.new
      @in = 21.31
      @mb = 721.64
    end
    
    it "returns MB if it exists" do
      @pressure.mb = @mb
      @pressure.millibars.should == @mb
      @pressure.mb(false).should == @mb
    end
    
    it "auto converts from IN if MB is nil and IN exists" do
      @pressure.in = @in
      @pressure.inches.should == @in
      @pressure.millibars.should be_nil
      @pressure.mb(false).should == @mb
    end
    
    it "allows a float to be returned for MB" do
      mb = 721.12
      @pressure.mb = mb
      @pressure.millibars.should == mb
      @pressure.mb(true).should == mb.to_i
      @pressure.mb(false).should == mb.to_f
    end
      
    it "allows only 2 decimal precision for MB" do
      mb = 721.1234
      @pressure.mb = mb
      @pressure.millibars.should == mb
      @pressure.mb(false).should == 721.12
    end
    
    it "returns IN if it exists" do
      @pressure.in = @in
      @pressure.inches.should == @in
      @pressure.in(false).should == @in
    end
    
    it "auto converts from MB if IN is nil and MB exists" do
      @pressure.mb = @mb
      @pressure.millibars.should == @mb
      @pressure.inches.should be_nil
      @pressure.in(false).should == @in
    end
    
    it "allows a float to be returned for IN" do
      inches = 21.12
      @pressure.in = inches
      @pressure.inches.should == inches
      @pressure.in(true).should == inches.to_i
      @pressure.in(false).should == inches.to_f
    end
      
    it "allows only 2 decimal precision for IN" do
      inches = 21.1234
      @pressure.in = inches
      @pressure.inches.should == inches
      @pressure.in(false).should == 21.12
    end
    
  end
  
  describe "operators" do
    
    before(:each) do
      @in = 21.31
      @mb = 721.64
      @pressure_low = Barometer::Pressure.new
      @pressure_low.mb = (@mb - 1.0)
      @pressure_high = Barometer::Pressure.new
      @pressure_high.mb = (@mb + 1.0)
      @pressure = Barometer::Pressure.new
      @pressure.mb = @mb
      @pressure_same = Barometer::Pressure.new
      @pressure_same.mb = @mb
    end
    
    it "defines <=>" do
      Barometer::Pressure.method_defined?("<=>").should be_true
      (@pressure_low <=> @pressure_high).should == -1
      (@pressure_high <=> @pressure_low).should == 1
      (@pressure <=> @pressure_same).should == 0
    end
    
    it "defines <" do
      Barometer::Pressure.method_defined?("<").should be_true
      @pressure_low.should < @pressure_high
      @pressure_high.should_not < @pressure_low
      @pressure.should_not < @pressure_same
    end
    
    it "defines >" do
      Barometer::Pressure.method_defined?(">").should be_true
      @pressure_low.should_not > @pressure_high
      @pressure_high.should > @pressure_low
      @pressure.should_not > @pressure_same
    end
    
    it "defines ==" do
      Barometer::Pressure.method_defined?("==").should be_true
      @pressure_low.should_not == @pressure_high
      @pressure.should == @pressure_same
    end
    
    it "defines <=" do
      Barometer::Pressure.method_defined?("<=").should be_true
      @pressure_low.should <= @pressure_high
      @pressure_high.should_not <= @pressure_low
      @pressure.should <= @pressure_same
    end
    
    it "defines >=" do
      Barometer::Pressure.method_defined?(">=").should be_true
      @pressure_low.should_not >= @pressure_high
      @pressure_high.should >= @pressure_low
      @pressure.should >= @pressure_same
    end
    
  end
  
  describe "changing units" do
    
    before(:each) do
      @in = 21.31
      @mb = 721.64
      @pressure = Barometer::Pressure.new
      @pressure.mb = @mb
    end
    
    it "returns just the integer value (no units)" do
      @pressure.metric?.should be_true
      @pressure.to_i.should == @mb.to_i
      
      @pressure.imperial!
      @pressure.metric?.should be_false
      @pressure.to_i.should == @in.to_i
    end

    it "returns just the float value (no units)" do
      @pressure.metric?.should be_true
      @pressure.to_f.should == @mb.to_f

      @pressure.imperial!
      @pressure.metric?.should be_false
      @pressure.to_f.should == @in.to_f
    end
    
    it "returns just the integer value with units" do
      @pressure.metric?.should be_true
      @pressure.to_s.should == "#{@mb.to_i} #{Barometer::Pressure::METRIC_UNITS}"

      @pressure.imperial!
      @pressure.metric?.should be_false
      @pressure.to_s.should == "#{@in.to_i} #{Barometer::Pressure::IMPERIAL_UNITS}"
    end
    
    it "returns just the units" do
      @pressure.metric?.should be_true
      @pressure.units.should == Barometer::Pressure::METRIC_UNITS

      @pressure.imperial!
      @pressure.metric?.should be_false
      @pressure.units.should == Barometer::Pressure::IMPERIAL_UNITS
    end

  end
  
end