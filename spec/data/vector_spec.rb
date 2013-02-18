require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Data::Vector do
  describe "when initialized" do
    it "defines METRIC_UNITS" do
      Data::Vector.const_defined?("METRIC_UNITS").should be_true
      Data::Vector::METRIC_UNITS.should == "kph"
    end

    it "defines IMPERIAL_UNITS" do
      Data::Vector.const_defined?("IMPERIAL_UNITS").should be_true
      Data::Vector::IMPERIAL_UNITS.should == "mph"
    end

    before(:each) do
      @vector = Data::Vector.new
    end

    it "responds to kilometers" do
      @vector.kilometers.should be_nil
    end

    it "responds to miles" do
      @vector.miles.should be_nil
    end

    it "responds to degrees" do
      @vector.degrees.should be_nil
    end

    it "responds to direction" do
      @vector.direction.should be_nil
    end

    it "responds to metric_default" do
      lambda { @vector.metric_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to imperial_default" do
      lambda { @vector.imperial_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to nil?" do
      @vector.nil?.should be_true
      @vector.kph = 5
      @vector.nil?.should be_false
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
      Data::Vector.km_to_m(nil).should be_nil
      Data::Vector.m_to_km(nil).should be_nil

      not_float_or_integer = "string"
      Data::Vector.km_to_m(not_float_or_integer).should be_nil
      Data::Vector.m_to_km(not_float_or_integer).should be_nil
    end

    it "converts km/h to mph" do
      # to get equality, we need to tone down the precision
      ((Data::Vector.km_to_m(@km)*10).round/10.0).should == @m
    end

    it "converts mph to km/h" do
      Data::Vector.m_to_km(@m).should == @km
    end
  end

  describe "updating" do
    before(:each) do
      @vector = Data::Vector.new
      @m = 10.0
      @km = 16.09
    end

    it "nils M if new KM converts to a M that changes more then 1 unit" do
      @vector.miles = (@m + 1.1)
      @vector.update_miles(@km)
      @vector.miles.should be_nil
    end

    it "doesn't update M if new KM converts to a M that does not change more then 1 unit" do
      @vector.miles = (@m + 0.9)
      @vector.update_miles(@km)
      @vector.miles.should == (@m + 0.9)
    end

    it "doesn't set M if not already set" do
      @vector.miles.should be_nil
      @vector.kilometers.should be_nil
      @vector.update_miles(@km)
      @vector.miles.should be_nil
      @vector.kilometers.should be_nil
    end

    it "nils KM if new M converts to a KM that changes more then 1 unit" do
      @vector.kilometers = (@km + 1.1)
      @vector.update_kilometers(@m)
      @vector.kilometers.should be_nil
    end

    it "doesn't update KM if new M converts to a KM that does not change more then 1 unit" do
      @vector.kilometers = (@km + 0.9)
      @vector.update_kilometers(@m)
      @vector.kilometers.should == (@km + 0.9)
    end

    it "doesn't set KM if not already set" do
      @vector.miles.should be_nil
      @vector.kilometers.should be_nil
      @vector.update_kilometers(@m)
      @vector.miles.should be_nil
      @vector.kilometers.should be_nil
    end
  end

  describe "storing" do
    before(:each) do
      @vector = Data::Vector.new
      @m = 10.0
      @km = 16.09
    end

    it "doesn't update KM if nil value (or equivalent)" do
      @vector.kilometers.should be_nil
      @vector.kph = nil
      @vector.kilometers.should be_nil
      @vector.kph = "na"
      @vector.kilometers.should be_nil
    end

    it "stores KM and resets M" do
      @vector.kilometers.should be_nil
      @vector.miles = (@m + 1.1)
      @vector.kph = @km
      @vector.kilometers.should == @km
      @vector.miles.should be_nil
    end

    it "doesn't update M if nil value (or equivalent)" do
      @vector.miles.should be_nil
      @vector.mph = nil
      @vector.miles.should be_nil
      @vector.mph = "na"
      @vector.miles.should be_nil
    end

    it "stores M, resets KM" do
      @vector.miles.should be_nil
      @vector.kilometers = (@km + 1.1)
      @vector.mph = @m
      @vector.miles.should == @m
      @vector.kilometers.should be_nil
    end

    it "doesn't update direction if nil value (or equivalent)" do
      @vector.direction.should be_nil
      @vector.direction = nil
      @vector.direction.should be_nil
      @vector.direction = "na"
      @vector.direction.should_not be_nil
    end

    it "stores direction" do
      @vector.direction.should be_nil
      @vector.direction = "SSW"
      @vector.direction.should == "SSW"
    end

    it "doesn't update degrees if nil value (or equivalent)" do
      @vector.degrees.should be_nil
      @vector.degrees = nil
      @vector.degrees.should be_nil
      @vector.degrees = "na"
      @vector.degrees.should be_nil
    end

    it "stores degrees" do
      @vector.degrees.should be_nil
      @vector.degrees = 90.0
      @vector.degrees.should == 90.0
    end
  end

  describe "retrieving" do
    before(:each) do
      @vector = Data::Vector.new
      @m = 10.0
      @km = 16.09
    end

    it "returns KM if it exists" do
      @vector.kph = @km
      @vector.kilometers.should == @km
      @vector.kph(false).should == @km
    end

    it "auto converts from M if KM is nil and M exists" do
      @vector.mph = @m
      @vector.miles.should == @m
      @vector.kilometers.should be_nil
      @vector.kph(false).should == @km
    end

    it "allows a float to be returned for KM" do
      km = 16.12
      @vector.kph = km
      @vector.kilometers.should == km
      @vector.kph(true).should == km.to_i
      @vector.kph(false).should == km.to_f
    end

    it "allows only 2 decimal precision for KM" do
      km = 16.1234
      @vector.kph = km
      @vector.kilometers.should == km
      @vector.kph(false).should == 16.12
    end

    it "returns M if it exists" do
      @vector.mph = @m
      @vector.miles.should == @m
      @vector.mph.should == @m
    end

    it "auto converts from KM if M is nil and KM exists" do
      @vector.kph = @km
      @vector.kilometers.should == @km
      @vector.miles.should be_nil
      # to get equality, we need to tone down the precision
      ((@vector.mph*10).round/10.0).should == @m
    end

    it "allows a float to be returned for M" do
      m = 10.12
      @vector.mph = m
      @vector.miles.should == m
      @vector.mph(true).should == m.to_i
      @vector.mph(false).should == m.to_f
    end

    it "allows only 2 decimal precision for M" do
      m = 10.1234
      @vector.mph = m
      @vector.miles.should == m
      @vector.mph(false).should == 10.12
    end
  end

  describe "operators" do
    before(:each) do
      @m = 10.0
      @km = 16.09
      @vector_low = Data::Vector.new
      @vector_low.kph = (@km - 1.0)
      @vector_high = Data::Vector.new
      @vector_high.kph = (@km + 1.0)
      @vector = Data::Vector.new
      @vector.kph = @km
      @vector_same = Data::Vector.new
      @vector_same.kph = @km
    end

    it "defines <=>" do
      Data::Vector.method_defined?("<=>").should be_true
      (@vector_low <=> @vector_high).should == -1
      (@vector_high <=> @vector_low).should == 1
      (@vector <=> @vector_same).should == 0
    end

    it "defines <" do
      Data::Vector.method_defined?("<").should be_true
      @vector_low.should < @vector_high
      @vector_high.should_not < @vector_low
      @vector.should_not < @vector_same
    end

    it "defines >" do
      Data::Vector.method_defined?(">").should be_true
      @vector_low.should_not > @vector_high
      @vector_high.should > @vector_low
      @vector.should_not > @vector_same
    end

    it "defines ==" do
      Data::Vector.method_defined?("==").should be_true
      @vector_low.should_not == @vector_high
      @vector.should == @vector_same
    end

    it "defines <=" do
      Data::Vector.method_defined?("<=").should be_true
      @vector_low.should <= @vector_high
      @vector_high.should_not <= @vector_low
      @vector.should <= @vector_same
    end

    it "defines >=" do
      Data::Vector.method_defined?(">=").should be_true
      @vector_low.should_not >= @vector_high
      @vector_high.should >= @vector_low
      @vector.should >= @vector_same
    end
  end

  describe "changing units" do
    before(:each) do
      @m = 10.51
      @km = ((Data::Vector.m_to_km(@m)*100).round/100.0)
      @vector = Data::Vector.new
      @vector.mph = @m
    end

    it "returns just the integer value (no units)" do
      @vector.metric?.should be_true
      @vector.to_i.should == @km.to_i

      @vector.imperial!
      @vector.metric?.should be_false
      @vector.to_i.should == @m.to_i
    end

    it "returns just the float value (no units)" do
      @vector.metric?.should be_true
      @vector.to_f.should == @km.to_f

      @vector.imperial!
      @vector.metric?.should be_false
      @vector.to_f.should == @m.to_f
    end

    it "returns just the integer value with units" do
      @vector.metric?.should be_true
      @vector.to_s.should == "#{@km.to_i} #{Data::Vector::METRIC_UNITS}"

      @vector.imperial!
      @vector.metric?.should be_false
      @vector.to_s.should == "#{@m.to_i} #{Data::Vector::IMPERIAL_UNITS}"
    end

    it "returns just the units" do
      @vector.metric?.should be_true
      @vector.units.should == Data::Vector::METRIC_UNITS

      @vector.imperial!
      @vector.metric?.should be_false
      @vector.units.should == Data::Vector::IMPERIAL_UNITS
    end
  end

  describe "#speed" do
    it "sets kph" do
      vector = Data::Vector.new(true)
      vector.kph.should be_nil
      vector.mph.should be_nil
      vector.speed = 10.0
      vector.kph.should == 10.0
      vector.mph.should_not == 10.0
    end

    it "sets mph" do
      vector = Data::Vector.new(false)
      vector.mph.should be_nil
      vector.kph.should be_nil
      vector.speed = 10.0
      vector.mph.should == 10.0
      vector.kph.should_not == 10.0
    end
  end

  describe "#to_s" do
    before { subject << 22 }

    it "returns the speed, when no direction exists" do
      subject.to_s.should == "22 kph"
    end

    it "returns the speed plus direction, when direction exists" do
      subject.direction = "NE"
      subject.to_s.should == "22 kph NE"
    end

    it "returns the speed plus direction, when the degrees exist" do
      subject.degrees = 180
      subject.to_s.should == "22 kph @ 180 degrees"
    end

    it "returns the speed plus direction, preffering direction over degrees" do
      subject.direction = "NE"
      subject.degrees = 180
      subject.to_s.should == "22 kph NE"
    end
  end
end
