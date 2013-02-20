require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Data::Temperature do
  describe "when initialized" do
    it "defines METRIC_UNITS" do
      Data::Temperature.const_defined?("METRIC_UNITS").should be_true
      Data::Temperature::METRIC_UNITS.should == "C"
    end

    it "defines IMPERIAL_UNITS" do
      Data::Temperature.const_defined?("IMPERIAL_UNITS").should be_true
      Data::Temperature::IMPERIAL_UNITS.should == "F"
    end

    before(:each) do
      @temp = Data::Temperature.new
    end

    it "responds to celcius" do
      @temp.celsius.should be_nil
    end

    it "responds to fahrenheit" do
      @temp.fahrenheit.should be_nil
    end

    it "responds to kelvin" do
      @temp.kelvin.should be_nil
    end

    it "responds to metric_default" do
      lambda { @temp.metric_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to imperial_default" do
      lambda { @temp.imperial_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to nil?" do
      @temp.nil?.should be_true
      @temp.c = 5
      @temp.nil?.should be_false
    end
  end

  describe "conversion" do
    # For all conversions
    # 20.0 C = 293.15 K = 68.0 F
    before(:each) do
      @f = 68.0
      @c = 20.0
      @k = 293.15
    end

    it "requires a value, that is either Integer or Float" do
      Data::Temperature.c_to_k(nil).should be_nil
      Data::Temperature.c_to_f(nil).should be_nil
      Data::Temperature.f_to_k(nil).should be_nil
      Data::Temperature.f_to_c(nil).should be_nil
      Data::Temperature.k_to_c(nil).should be_nil
      Data::Temperature.k_to_f(nil).should be_nil

      not_float_or_integer = "string"
      Data::Temperature.c_to_k(not_float_or_integer).should be_nil
      Data::Temperature.c_to_f(not_float_or_integer).should be_nil
      Data::Temperature.f_to_k(not_float_or_integer).should be_nil
      Data::Temperature.f_to_c(not_float_or_integer).should be_nil
      Data::Temperature.k_to_c(not_float_or_integer).should be_nil
      Data::Temperature.k_to_f(not_float_or_integer).should be_nil
    end

    it "converts C to K" do
      # 0 C = 273.15 K
      Data::Temperature.c_to_k(@c).should == @k
    end

    it "converts C to F" do
      # Tf = (9/5)*Tc+32
      Data::Temperature.c_to_f(@c).should == @f
    end

    it "converts F to C" do
      # Tc = (5/9)*(Tf-32)
      Data::Temperature.f_to_c(@f).should == @c
    end

    it "converts F to K" do
      Data::Temperature.f_to_k(@f).should == @k
    end

    it "converts K to C" do
      Data::Temperature.k_to_c(@k).should == @c
    end

    it "converts K to F" do
      Data::Temperature.k_to_f(@k).should == @f
    end
  end

  describe "updating" do
    before(:each) do
      @temp = Data::Temperature.new
      @f = 68.0
      @c = 20.0
    end

    it "nils F if new C converts to a F that changes more then 1 degree" do
      @temp.fahrenheit = (@f + 1.1)
      @temp.update_fahrenheit(@c)
      @temp.fahrenheit.should be_nil
    end

    it "doesn't update F if new C converts to a F that does not change more then 1 degree" do
      @temp.fahrenheit = (@f + 0.9)
      @temp.update_fahrenheit(@c)
      @temp.fahrenheit.should == (@f + 0.9)
    end

    it "doesn't set F if not already set" do
      @temp.fahrenheit.should be_nil
      @temp.celsius.should be_nil
      @temp.update_fahrenheit(@c)
      @temp.fahrenheit.should be_nil
      @temp.celsius.should be_nil
    end

    it "nils C if new F converts to a C that changes more then 1 degree" do
      @temp.celsius = (@c + 1.1)
      @temp.update_celsius(@f)
      @temp.celsius.should be_nil
    end

    it "doesn't update C if new F converts to a C that does not change more then 1 degree" do
      @temp.celsius = (@c + 0.9)
      @temp.update_celsius(@f)
      @temp.celsius.should == (@c + 0.9)
    end

    it "doesn't set C if not already set" do
      @temp.fahrenheit.should be_nil
      @temp.celsius.should be_nil
      @temp.update_celsius(@f)
      @temp.fahrenheit.should be_nil
      @temp.celsius.should be_nil
    end
  end

  describe "storing" do
    before(:each) do
      @temp = Data::Temperature.new
      @f = 68.0
      @c = 20.0
      @k = 293.15
    end

    it "doesn't update C if nil value (or equivalent)" do
      @temp.celsius.should be_nil
      @temp.c = nil
      @temp.celsius.should be_nil
      @temp.c = "na"
      @temp.celsius.should be_nil
    end

    it "stores C, convert to K and reset F" do
      @temp.celsius.should be_nil
      @temp.fahrenheit = (@f + 1.1)
      @temp.kelvin.should be_nil
      @temp.c = @c
      @temp.celsius.should == @c
      @temp.kelvin.should == @k
      @temp.fahrenheit.should be_nil
    end

    it "doesn't update F if nil value (or equivalent)" do
      @temp.fahrenheit.should be_nil
      @temp.f = nil
      @temp.fahrenheit.should be_nil
      @temp.f = "na"
      @temp.fahrenheit.should be_nil
    end

    it "stores F, convert to K and reset C" do
      @temp.fahrenheit.should be_nil
      @temp.celsius = (@c + 1.1)
      @temp.kelvin.should be_nil
      @temp.f = @f
      @temp.fahrenheit.should == @f
      @temp.kelvin.should == @k
      @temp.celsius.should be_nil
    end

    it "doesn't update K if nil value (or equivalent)" do
      @temp.kelvin.should be_nil
      @temp.k = nil
      @temp.kelvin.should be_nil
      @temp.k = "na"
      @temp.kelvin.should be_nil
    end

    it "stores K, convert to F and C" do
      @temp.celsius.should be_nil
      @temp.fahrenheit.should be_nil
      @temp.kelvin.should be_nil
      @temp.k = @k
      @temp.celsius.should == @c
      @temp.fahrenheit.should == @f
      @temp.kelvin.should == @k
    end
  end

  describe "retrieving" do
    before(:each) do
      @temp = Data::Temperature.new
      @f = 68.0
      @c = 20.0
      @k = 293.15
    end

    it "returns C if it exists" do
      @temp.c = @c
      @temp.celsius.should == @c
      @temp.c.should == @c
    end

    it "auto converts from K if C is nil and K exists" do
      @temp.f = @f
      @temp.fahrenheit.should == @f
      @temp.kelvin.should == @k
      @temp.celsius.should be_nil
      @temp.c.should == @c
    end

    it "allows a float to be returned for C" do
      c = 20.12
      @temp.c = c
      @temp.celsius.should == c
      @temp.c(true).should == c.to_i
      @temp.c(false).should == c.to_f
    end

    it "allows only 2 decimal precision for C" do
      c = 20.1234
      @temp.c = c
      @temp.celsius.should == c
      @temp.c(false).should == 20.12
    end

    it "returns F if it exists" do
      @temp.f = @f
      @temp.fahrenheit.should == @f
      @temp.f.should == @f
    end

    it "auto converts from K if F is nil and K exists" do
      @temp.c = @c
      @temp.celsius.should == @c
      @temp.kelvin.should == @k
      @temp.fahrenheit.should be_nil
      @temp.f.should == @f
    end

    it "allows a float to be returned for F" do
      f = 68.12
      @temp.f = f
      @temp.fahrenheit.should == f
      @temp.f(true).should == f.to_i
      @temp.f(false).should == f.to_f
    end

    it "allows only 2 decimal precision for F" do
      f = 68.1234
      @temp.f = f
      @temp.fahrenheit.should == f
      @temp.f(false).should == 68.12
    end
  end

  describe "operators" do
    before(:each) do
      @f = 68.0
      @c = 20.0
      @k = 293.15
      @temp_low = Data::Temperature.new
      @temp_low.k = (@k - 1.0)
      @temp_high = Data::Temperature.new
      @temp_high.k = (@k + 1.0)
      @temp = Data::Temperature.new
      @temp.k = @k
      @temp_same = Data::Temperature.new
      @temp_same.k = @k
    end

    it "defines <=>" do
      Data::Temperature.method_defined?("<=>").should be_true
      (@temp_low <=> @temp_high).should == -1
      (@temp_high <=> @temp_low).should == 1
      (@temp <=> @temp_same).should == 0
    end

    it "defines <" do
      Data::Temperature.method_defined?("<").should be_true
      @temp_low.should < @temp_high
      @temp_high.should_not < @temp_low
      @temp.should_not < @temp_same
    end

    it "defines >" do
      Data::Temperature.method_defined?(">").should be_true
      @temp_low.should_not > @temp_high
      @temp_high.should > @temp_low
      @temp.should_not > @temp_same
    end

    it "defines ==" do
      Data::Temperature.method_defined?("==").should be_true
      @temp_low.should_not == @temp_high
      @temp.should == @temp_same
    end

    it "defines <=" do
      Data::Temperature.method_defined?("<=").should be_true
      @temp_low.should <= @temp_high
      @temp_high.should_not <= @temp_low
      @temp.should <= @temp_same
    end

    it "defines >=" do
      Data::Temperature.method_defined?(">=").should be_true
      @temp_low.should_not >= @temp_high
      @temp_high.should >= @temp_low
      @temp.should >= @temp_same
    end
  end

  describe "changing units" do
    before(:each) do
      @c = 20.5
      @f = Data::Temperature.c_to_f(@c)
      @k = Data::Temperature.c_to_k(@c)
      @temp = Data::Temperature.new
      @temp.k = @k
    end

    it "returns just the integer value (no units)" do
      @temp.metric?.should be_true
      @temp.to_i.should == @c.to_i

      @temp.imperial!
      @temp.metric?.should be_false
      @temp.to_i.should == @f.to_i
    end

    it "returns just the float value (no units)" do
      @temp.metric?.should be_true
      @temp.to_f.should == @c.to_f

      @temp.imperial!
      @temp.metric?.should be_false
      @temp.to_f.should == @f.to_f
    end

    it "returns just the integer value with units" do
      @temp.metric?.should be_true
      @temp.to_s.should == "#{@c.to_i} #{Data::Temperature::METRIC_UNITS}"

      @temp.imperial!
      @temp.metric?.should be_false
      @temp.to_s.should == "#{@f.to_i} #{Data::Temperature::IMPERIAL_UNITS}"
    end

    it "returns just the units" do
      @temp.metric?.should be_true
      @temp.units.should == Data::Temperature::METRIC_UNITS

      @temp.imperial!
      @temp.metric?.should be_false
      @temp.units.should == Data::Temperature::IMPERIAL_UNITS
    end
  end

  describe "#to_s" do
    it "returns the value and units when a value exists" do
      subject << 10
      subject.to_s.should == "10 C"
    end

    it "returns nothing when no value exists" do
      subject << nil
      subject.to_s.should == ""
    end
  end
end
