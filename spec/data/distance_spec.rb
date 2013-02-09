require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Data::Distance" do

  describe "when initialized" do

    it "defines METRIC_UNITS" do
      Data::Distance.const_defined?("METRIC_UNITS").should be_true
      Data::Distance::METRIC_UNITS.should == "km"
    end

    it "defines IMPERIAL_UNITS" do
      Data::Distance.const_defined?("IMPERIAL_UNITS").should be_true
      Data::Distance::IMPERIAL_UNITS.should == "m"
    end

    before(:each) do
      @distance = Data::Distance.new
    end

    it "responds to kilometers" do
      @distance.kilometers.should be_nil
    end

    it "responds to miles" do
      @distance.miles.should be_nil
    end

    it "responds to metric_default" do
      lambda { @distance.metric_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to imperial_default" do
      lambda { @distance.imperial_default = 5 }.should_not raise_error(NotImplementedError)
    end

    it "responds to nil?" do
      @distance.nil?.should be_true
      @distance.km = 5
      @distance.nil?.should be_false
    end

  end

  describe "conversion" do

    # For all conversions
    # 26.2 M = 42.2 KM
    before(:each) do
      @m = 26.2
      @km = 42.2
    end

    it "requires a value, that is either Integer or Float" do
      Data::Distance.km_to_m(nil).should be_nil
      Data::Distance.m_to_km(nil).should be_nil

      not_float_or_integer = "string"
      Data::Distance.km_to_m(not_float_or_integer).should be_nil
      Data::Distance.m_to_km(not_float_or_integer).should be_nil
    end

    it "converts KM to M" do
      ((Data::Distance.km_to_m(@km)*10).round/10.0).should == @m
    end

    it "converts M to KM" do
      ((Data::Distance.m_to_km(@m)*10).round/10.0).should == @km
    end

  end

  describe "updating" do

    before(:each) do
      @distance = Data::Distance.new
      @m = 26.2
      @km = 42.2
    end

    it "nils M if new KM converts to a M that changes more then 1 unit" do
      @distance.miles = (@m + 1.1)
      @distance.update_miles(@km)
      @distance.miles.should be_nil
    end

    it "doesn't update M if new KM converts to a M that does not change more then 1 unit" do
      @distance.miles = (@m + 0.9)
      @distance.update_miles(@km)
      @distance.miles.should == (@m + 0.9)
    end

    it "doesn't set M if not already set" do
      @distance.miles.should be_nil
      @distance.kilometers.should be_nil
      @distance.update_miles(@km)
      @distance.miles.should be_nil
      @distance.kilometers.should be_nil
    end

    it "nils KM if new M converts to a KM that changes more then 1 unit" do
      @distance.kilometers = (@km + 1.1)
      @distance.update_kilometers(@m)
      @distance.kilometers.should be_nil
    end

    it "doesn't update KM if new M converts to a KM that does not change more then 1 unit" do
      @distance.kilometers = (@km + 0.9)
      @distance.update_kilometers(@m)
      @distance.kilometers.should == (@km + 0.9)
    end

    it "doesn't set KM if not already set" do
      @distance.miles.should be_nil
      @distance.kilometers.should be_nil
      @distance.update_kilometers(@m)
      @distance.miles.should be_nil
      @distance.kilometers.should be_nil
    end

  end

  describe "storing" do

    before(:each) do
      @distance = Data::Distance.new
      @m = 26.2
      @km = 42.2
    end

    it "doesn't update KM if nil value (or equivalent)" do
      @distance.kilometers.should be_nil
      @distance.km = nil
      @distance.kilometers.should be_nil
      @distance.km = "na"
      @distance.kilometers.should be_nil
    end

    it "stores KM and resets M" do
      @distance.kilometers.should be_nil
      @distance.miles = (@m + 1.1)
      @distance.km = @km
      @distance.kilometers.should == @km
      @distance.miles.should be_nil
    end

    it "doesn't update M if nil value (or equivalent)" do
      @distance.miles.should be_nil
      @distance.m = nil
      @distance.miles.should be_nil
      @distance.m = "na"
      @distance.miles.should be_nil
    end

    it "stores M and resets KM" do
      @distance.miles.should be_nil
      @distance.kilometers = (@km + 1.1)
      @distance.m = @m
      @distance.miles.should == @m
      @distance.kilometers.should be_nil
    end

  end

  describe "retrieving" do

    before(:each) do
      @distance = Data::Distance.new
      @m = 26.2
      @km = 42.16
    end

    it "returns KM if it exists" do
      @distance.km = @km
      @distance.kilometers.should == @km
      @distance.km(false).should == @km
    end

    it "auto converts from M if KM is nil and M exists" do
      @distance.m = @m
      @distance.miles.should == @m
      @distance.kilometers.should be_nil
      @distance.km(false).should == @km
    end

    it "allows a float to be returned for KM" do
      km = 42.12
      @distance.km = km
      @distance.kilometers.should == km
      @distance.km(true).should == km.to_i
      @distance.km(false).should == km.to_f
    end

    it "allows only 2 decimal precision for KM" do
      km = 42.1234
      @distance.km = km
      @distance.kilometers.should == km
      @distance.km(false).should == 42.12
    end

    it "returns M if it exists" do
      @distance.m = @m
      @distance.miles.should == @m
      @distance.m(false).should == @m
    end

    it "auto converts from KM if M is nil and KM exists" do
      @distance.km = @km
      @distance.kilometers.should == @km
      @distance.miles.should be_nil
      ((@distance.m(false)*10).round/10.0).should == @m
    end

    it "allows a float to be returned for M" do
      m = 26.12
      @distance.m = m
      @distance.miles.should == m
      @distance.m(true).should == m.to_i
      @distance.m(false).should == m.to_f
    end

    it "allows only 2 decimal precision for M" do
      m = 26.1234
      @distance.m = m
      @distance.miles.should == m
      @distance.m(false).should == 26.12
    end

  end

  describe "operators" do

    before(:each) do
      @m = 26.2
      @km = 42.16
      @distance_low = Data::Distance.new
      @distance_low.km = (@m - 1.0)
      @distance_high = Data::Distance.new
      @distance_high.km = (@km + 1.0)
      @distance = Data::Distance.new
      @distance.km = @km
      @distance_same = Data::Distance.new
      @distance_same.km = @km
    end

    it "defines <=>" do
      Data::Distance.method_defined?("<=>").should be_true
      (@distance_low <=> @distance_high).should == -1
      (@distance_high <=> @distance_low).should == 1
      (@distance <=> @distance_same).should == 0
    end

    it "defines <" do
      Data::Distance.method_defined?("<").should be_true
      @distance_low.should < @distance_high
      @distance_high.should_not < @distance_low
      @distance.should_not < @distance_same
    end

    it "defines >" do
      Data::Distance.method_defined?(">").should be_true
      @distance_low.should_not > @distance_high
      @distance_high.should > @distance_low
      @distance.should_not > @distance_same
    end

    it "defines ==" do
      Data::Distance.method_defined?("==").should be_true
      @distance_low.should_not == @distance_high
      @distance.should == @distance_same
    end

    it "defines <=" do
      Data::Distance.method_defined?("<=").should be_true
      @distance_low.should <= @distance_high
      @distance_high.should_not <= @distance_low
      @distance.should <= @distance_same
    end

    it "defines >=" do
      Data::Distance.method_defined?(">=").should be_true
      @distance_low.should_not >= @distance_high
      @distance_high.should >= @distance_low
      @distance.should >= @distance_same
    end

  end

  describe "changing units" do

    before(:each) do
      @m = 26.2
      @km = 42.16
      @distance = Data::Distance.new
      @distance.km = @km
    end

    it "returns just the integer value (no units)" do
      @distance.metric?.should be_true
      @distance.to_i.should == @km.to_i

      @distance.imperial!
      @distance.metric?.should be_false
      @distance.to_i.should == @m.to_i
    end

    it "returns just the float value (no units)" do
      @distance.metric?.should be_true
      @distance.to_f.should == @km.to_f

      @distance.imperial!
      @distance.metric?.should be_false
      ((@distance.to_f*10).round/10.0).should == @m.to_f
    end

    it "returns just the integer value with units" do
      @distance.metric?.should be_true
      @distance.to_s.should == "#{@km.to_i} #{Data::Distance::METRIC_UNITS}"

      @distance.imperial!
      @distance.metric?.should be_false
      @distance.to_s.should == "#{@m.to_i} #{Data::Distance::IMPERIAL_UNITS}"
    end

    it "returns just the units" do
      @distance.metric?.should be_true
      @distance.units.should == Data::Distance::METRIC_UNITS

      @distance.imperial!
      @distance.metric?.should be_false
      @distance.units.should == Data::Distance::IMPERIAL_UNITS
    end

  end

end
