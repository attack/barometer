require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestClass
  include Barometer::DataTypes

  temperature :temperature
  vector :vector
  pressure :pressure
  distance :distance
  float :float
  integer :integer
  string :string
  local_datetime :local_datetime
  local_time :local_time
  time :time
  sun :sun
  location :location
  timezone :timezone
  boolean :boolean
  symbol :symbol
end

describe Barometer::DataTypes do
  subject { TestClass.new }

  describe "#metric" do
    it "sets anything truthy to true" do
      subject.metric = false

      subject.metric = true
      subject.metric.should == true

      subject.metric = "true"
      subject.metric.should == true

      subject.metric = "0"
      subject.metric.should == true

      subject.metric = 0
      subject.metric.should == true

      subject.metric = []
      subject.metric.should == true
    end

    it "sets anything falsy to false" do
      subject.metric = true

      subject.metric = false
      subject.metric.should == false

      subject.metric = nil
      subject.metric.should == false
    end
  end

  describe "#metric?" do
    it "returns true when metric is nil" do
      subject.metric.should be_nil
      subject.metric?.should == true
    end

    it "returns true when metric is true" do
      subject.metric = true
      subject.metric?.should == true
    end

    it "returns false when metric is false" do
      subject.metric = false
      subject.metric?.should == false
    end
  end

  describe "temperature" do
    it { should respond_to :temperature }
    it { should respond_to :temperature= }

    context "when setting to nil" do
      it "equals nil" do
        subject.temperature = nil
        subject.temperature.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Barometer::Data::Temperature" do
        subject.temperature = [12]
        subject.temperature.should be_a(Barometer::Data::Temperature)
      end

      it "prints correctly" do
        subject.temperature = [12]
        subject.temperature.to_s.should == "12 C"
      end

      it "does not clear the value" do
        subject.temperature = [12]
        subject.temperature = nil
        subject.temperature.to_s.should == "12 C"
      end
    end

    context "when setting with Barometer::Data::Temperature" do
      it "uses the passed in value" do
        temperature = Barometer::Data::Temperature.new(12)
        subject.temperature = temperature
        subject.temperature.should be_a(Barometer::Data::Temperature)
        subject.temperature.should == temperature
        subject.temperature.object_id.should == temperature.object_id
      end
    end

    context "when setting to multiple values" do
      it "initializes Barometer::Data::Temperature" do
        subject.temperature = [12, 53]
        subject.temperature.should be_a(Barometer::Data::Temperature)
      end

      it "prints correctly (as metric)" do
        subject.temperature = [12, 53]
        subject.temperature.to_s.should == "12 C"
      end

      it "prints correctly (as imperial)" do
        subject.temperature = [12, 53]
        subject.metric = false
        subject.temperature.to_s.should == "53 F"
      end
    end

    context "when changing metric" do
      it "adjusts correctly" do
        subject.metric = true
        subject.temperature = [12, 53]
        subject.temperature.to_s.should == "12 C"

        subject.metric = false
        subject.temperature.to_s.should == "53 F"
      end
    end
  end

  describe "vector" do
    it { should respond_to :vector }
    it { should respond_to :vector= }

    context "when setting to nil" do
      it "equals nil" do
        subject.vector = nil
        subject.vector.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Barometer::Data::Vector" do
        subject.vector = [12, 270]
        subject.vector.should be_a(Barometer::Data::Vector)
      end

      it "prints correctly" do
        subject.vector = [12]
        subject.vector.to_s.should == "12 kph"
      end

      it "does not clear the value" do
        subject.vector = [12]
        subject.vector = nil
        subject.vector.to_s.should == "12 kph"
      end
    end

    context "when setting with Barometer::Data::Vector" do
      it "uses the passed in value" do
        vector = Barometer::Data::Vector.new(12, 270)
        subject.vector = vector
        subject.vector.should be_a(Barometer::Data::Vector)
        subject.vector.should == vector
        subject.vector.object_id.should == vector.object_id
      end
    end

    context "when changing metric" do
      it "adjusts correctly" do
        subject.metric = true
        subject.vector = [16.1]
        subject.vector.to_s.should == "16.1 kph"

        subject.metric = false
        subject.vector.to_s.should == "10.0 mph"
      end
    end
  end

  describe "pressure" do
    it { should respond_to :pressure }
    it { should respond_to :pressure= }

    context "when setting to nil" do
      it "equals nil" do
        subject.pressure = nil
        subject.pressure.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Barometer::Data::Pressure" do
        subject.pressure = [12]
        subject.pressure.should be_a(Barometer::Data::Pressure)
      end

      it "prints correctly" do
        subject.pressure = [12]
        subject.pressure.to_s.should == "12 mb"
      end

      it "does not clear the value" do
        subject.pressure = [12]
        subject.pressure = nil
        subject.pressure.to_s.should == "12 mb"
      end
    end

    context "when setting to multiple values" do
      it "initializes Barometer::Data::Pressure" do
        subject.pressure = [1234, 36]
        subject.pressure.should be_a(Barometer::Data::Pressure)
      end

      it "prints correctly (as metric)" do
        subject.pressure = [1234, 36]
        subject.pressure.to_s.should == "1234 mb"
      end

      it "prints correctly (as imperial)" do
        subject.pressure = [1234, 36]
        subject.metric = false
        subject.pressure.to_s.should == "36 in"
      end
    end

    context "when setting with Barometer::Data::Pressure" do
      it "uses the passed in value" do
        pressure = Barometer::Data::Pressure.new(12)
        subject.pressure = pressure
        subject.pressure.should be_a(Barometer::Data::Pressure)
        subject.pressure.should == pressure
        subject.pressure.object_id.should == pressure.object_id
      end
    end

    context "when changing metric" do
      it "adjusts correctly" do
        subject.metric = true
        subject.pressure = [1234]
        subject.pressure.to_s.should == "1234 mb"

        subject.metric = false
        subject.pressure.to_s.should == "36.4 in"
      end
    end
  end

  describe "distance" do
    it { should respond_to :distance }
    it { should respond_to :distance= }

    context "when setting to nil" do
      it "equals nil" do
        subject.distance = nil
        subject.distance.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Barometer::Data::Distance" do
        subject.distance = [42.2]
        subject.distance.should be_a(Barometer::Data::Distance)
      end

      it "prints correctly" do
        subject.distance = [42.2]
        subject.distance.to_s.should == "42.2 km"
      end

      it "does not clear the value" do
        subject.distance = [42.2]
        subject.distance = nil
        subject.distance.to_s.should == "42.2 km"
      end
    end

    context "when setting to multiple values" do
      it "initializes Barometer::Data::Distance" do
        subject.distance = [42.2, 26.2]
        subject.distance.should be_a(Barometer::Data::Distance)
      end

      it "prints correctly (as metric)" do
        subject.distance = [42.2, 26.2]
        subject.distance.to_s.should == "42.2 km"
      end

      it "prints correctly (as imperial)" do
        subject.distance = [42.2, 26.2]
        subject.metric = false
        subject.distance.to_s.should == "26.2 m"
      end
    end

    context "when setting with Barometer::Data::Distance" do
      it "uses the passed in value" do
        distance = Barometer::Data::Distance.new(42.2)
        subject.distance = distance
        subject.distance.should be_a(Barometer::Data::Distance)
        subject.distance.should == distance
        subject.distance.object_id.should == distance.object_id
      end
    end

    context "when changing metric" do
      it "adjusts correctly" do
        subject.metric = true
        subject.distance = [42.2]
        subject.distance.to_s.should == "42.2 km"

        subject.metric = false
        subject.distance.to_s.should == "26.2 m"
      end
    end
  end

  describe "float" do
    it { should respond_to :float }
    it { should respond_to :float= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.float.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.float = nil
        subject.float.should be_nil
      end
    end

    context "when setting with data to be interpretted as Float" do
      it "returns a Float" do
        subject.float = "12 cats"
        subject.float.should be_a(Float)
      end

      it "sets the value" do
        subject.float = "12 cats"
        subject.float.should == 12.0
      end

      it "clears the value" do
        subject.float = 12.0
        subject.float = nil
        subject.float.should be_nil
      end
    end

    context "when setting with Float" do
      it "uses the passed in value" do
        float = 9.0
        subject.float = float
        subject.float.should be_a(Float)
        subject.float.should == float
        subject.float.object_id.should == float.object_id
      end
    end
  end

  describe "integer" do
    it { should respond_to :integer }
    it { should respond_to :integer= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.integer.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.integer = nil
        subject.integer.should be_nil
      end
    end

    context "when setting with data to be interpretted as Integer" do
      it "returns a Integer" do
        subject.integer = "12 cats"
        subject.integer.should be_a(Integer)
      end

      it "sets the value" do
        subject.integer = "12 cats"
        subject.integer.should == 12
      end

      it "clears the value" do
        subject.integer = 12
        subject.integer = nil
        subject.integer.should be_nil
      end
    end

    context "when setting with Integer" do
      it "uses the passed in value" do
        integer = 9
        subject.integer = integer
        subject.integer.should be_a(Integer)
        subject.integer.should == integer
        subject.integer.object_id.should == integer.object_id
      end
    end
  end

  describe "string" do
    it { should respond_to :string }
    it { should respond_to :string= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.string.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.string = nil
        subject.string.should be_nil
      end
    end

    context "when setting with data to be interpretted as a String" do
      it "returns a String" do
        subject.string = 12
        subject.string.should be_a(String)
      end

      it "sets the value" do
        subject.string = 12
        subject.string.to_s.should == "12"
      end

      it "clears the value" do
        subject.string = "bar"
        subject.string = nil
        subject.string.should be_nil
      end
    end

    context "when setting with String" do
      it "uses the passed in value" do
        text = String.new("bar")
        subject.string = text
        subject.string.should be_a(String)
        subject.string.should == text
        subject.string.object_id.should == text.object_id
      end
    end
  end

  describe "symbol" do
    it { should respond_to :symbol }
    it { should respond_to :symbol= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.symbol.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.symbol = nil
        subject.symbol.should be_nil
      end
    end

    context "when setting with data to be interpretted as a Symbol" do
      it "returns a Symbol" do
        subject.symbol = "bar"
        subject.symbol.should be_a(Symbol)
      end

      it "sets the value" do
        subject.symbol = "bar"
        subject.symbol.should == :bar
      end
    end

    context "when setting with data that can't be converted to a Symbol" do
      it "returns nil" do
        expect {
          subject.symbol = []
        }.to raise_error{ ArgumentError }
      end
    end

    context "when setting with Symbol" do
      it "uses the passed in value" do
        symbol = :foo
        subject.symbol = symbol
        subject.symbol.should be_a(Symbol)
        subject.symbol.should == symbol
        subject.symbol.object_id.should == symbol.object_id
      end
    end
  end

  describe "local_datetime" do
    it { should respond_to :local_datetime }
    it { should respond_to :local_datetime= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.local_datetime.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.local_datetime = nil
        subject.local_datetime.should be_nil
      end
    end

    context "when setting with data to be interpretted as a local_datetime" do
      it "sets the value" do
        subject.local_datetime = 2012, 10, 4, 5, 30, 45
        subject.local_datetime.should == Barometer::Data::LocalDateTime.new(2012, 10, 4, 5, 30, 45)
      end

      it "clears the value" do
        subject.local_datetime = 2012, 10, 4, 5, 30, 45
        subject.local_datetime = nil
        subject.local_datetime.should be_nil
      end
    end

    context "when setting with data to parse" do
      it "sets the value" do
        subject.local_datetime = "2012-10-4 5:30:45 pm"
        subject.local_datetime.should == Barometer::Data::LocalDateTime.new(2012, 10, 4, 17, 30, 45)
      end
    end

    context "when setting with data to parse (including format)" do
      it "sets the value" do
        subject.local_datetime = "2012-10-04", "%Y-%d-%m"
        subject.local_datetime.should == Barometer::Data::LocalDateTime.new(2012, 4, 10)
      end
    end

    context "when setting with Barometer::Data::LocalDateTime" do
      it "uses the passed in value" do
        local_datetime = Barometer::Data::LocalDateTime.new(2012, 10, 4, 5, 30, 45)
        subject.local_datetime = local_datetime
        subject.local_datetime.should be_a(Barometer::Data::LocalDateTime)
        subject.local_datetime.should == local_datetime
        subject.local_datetime.object_id.should == local_datetime.object_id
      end
    end
  end

  describe "time" do
    it { should respond_to :time }
    it { should respond_to :time= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.time.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.time = nil
        subject.time.should be_nil
      end
    end

    context "when setting with data to be interpretted as a time" do
      it "sets the value" do
        subject.time = 2012, 10, 4, 5, 30, 45

        # 1.8.7 & 1.9.3 compatable
        subject.time.should == Time.local(2012, 10, 4, 5, 30, 45)
      end

      it "clears the value" do
        subject.time = 2012, 10, 4, 5, 30, 45
        subject.time = nil
        subject.time.should be_nil
      end
    end

    context "when setting with data to parse" do
      it "sets the value" do
        subject.time = "2012-10-4 5:30:45 pm UTC"

        # 1.8.7 & 1.9.3 compatable
        subject.time.should == Time.utc(2012, 10, 4, 17, 30, 45)
      end
    end

    context "when setting with data to parse (including format)" do
      it "sets the value" do
        subject.time = "2012-10-04", "%Y-%d-%m"

        # 1.8.7 & 1.9.3 compatable
        subject.time.should == Time.local(2012, 4, 10)
      end
    end

    context "when setting with DateTime" do
      it "uses the passed in value" do
        time = Time.now.utc
        subject.time = time
        subject.time.should be_a(Time)
        subject.time.should == time
        subject.time.object_id.should == time.object_id
      end
    end
  end

  describe "local_time" do
    it { should respond_to :local_time }
    it { should respond_to :local_time= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.local_time.should be_nil
      end
    end

    context "when setting to nil" do
      it "equals nil" do
        subject.local_time = nil
        subject.local_time.should be_nil
      end
    end

    context "when setting with data to be interpretted as a local_time" do
      it "sets the value" do
        subject.local_time = 5, 30, 45
        subject.local_time.should == Barometer::Data::LocalTime.new(5, 30, 45)
      end

      it "clears the value" do
        subject.local_time = 5, 30, 45
        subject.local_time = nil
        subject.local_time.should be_nil
      end
    end

    context "when setting with data to parse" do
      it "sets the value" do
        subject.local_time = "5:30:45 pm"
        subject.local_time.should == Barometer::Data::LocalTime.new(17, 30, 45)
      end
    end

    context "when setting with Barometer::Data::LocalTime" do
      it "uses the passed in value" do
        local_time = Barometer::Data::LocalTime.new(5, 30, 45)
        subject.local_time = local_time
        subject.local_time.should be_a(Barometer::Data::LocalTime)
        subject.local_time.should == local_time
        subject.local_time.object_id.should == local_time.object_id
      end
    end
  end

  describe "sun" do
    it { should respond_to :sun }
    it { should respond_to :sun= }

    context "when setting to nil" do
      it "equals nil" do
        subject.sun.rise = nil
        subject.sun.set = nil
        subject.sun.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Barometer::Data::Sun" do
        rise = Barometer::Data::LocalTime.new(5, 30, 45)
        subject.sun.rise = rise

        set = Barometer::Data::LocalTime.new(17, 30, 45)
        subject.sun.set = set

        subject.sun.rise.should == rise
        subject.sun.set.should == set
      end

      it "clears the value" do
        rise = Barometer::Data::LocalDateTime.new(2013, 02, 10, 6, 0, 0)
        set = Barometer::Data::LocalDateTime.new(2013, 02, 10, 6, 0, 0)
        subject.sun = Barometer::Data::Sun.new(rise, set)
        subject.sun = nil
        subject.sun.should be_nil
      end
    end

    context "when setting with invalid data" do
      it "raises an error" do
        expect {
          subject.sun = "foo"
        }.to raise_error{ ArgumentError }
      end
    end

    context "when setting with Barometer::Data::LocalTime" do
      it "uses the passed in value" do
        rise = Barometer::Data::LocalDateTime.new(2013, 02, 10, 6, 0, 0)
        set = Barometer::Data::LocalDateTime.new(2013, 02, 10, 6, 0, 0)
        sun = Barometer::Data::Sun.new(rise, set)
        subject.sun = sun
        subject.sun.should be_a(Barometer::Data::Sun)
        subject.sun.should == sun
        subject.sun.object_id.should == sun.object_id
      end
    end
  end

  describe "location" do
    it { should respond_to :location }
    it { should respond_to :location= }

    context "when nothing has been set" do
      it "returns a Barometer::Data::Location" do
        subject.location.should be_a(Barometer::Data::Location)
      end

      it "prints correctly" do
        subject.location.to_s.should == ""
      end
    end

    context "when setting with invalid data" do
      it "raises an error" do
        expect {
          subject.location = "foo"
        }.to raise_error{ ArgumentError }
      end
    end

    context "when setting attributes of location" do
      it "returns a Barometer::Data::Location" do
        subject.location.name = "foo"
        subject.location.should be_a(Barometer::Data::Location)
      end

      it "sets the value" do
        subject.location.name = "foo"
        subject.location.to_s.should == "foo"
      end

      it "resets the value" do
        subject.location.name = "bar"
        subject.location = nil
        subject.location.to_s.should == ""
      end
    end

    context "when setting with Barometer::Data::Location" do
      it "uses the passed in value" do
        location = Barometer::Data::Location.new
        location.name = "bar"
        subject.location = location
        subject.location.should be_a(Barometer::Data::Location)
        subject.location.should == location
        subject.location.object_id.should == location.object_id
      end
    end
  end

  describe "timezone" do
    it { should respond_to :timezone }
    it { should respond_to :timezone= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.timezone.should be_nil
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.timezone = nil
        subject.timezone.should be_nil
      end
    end

    context "when setting with data to be interpretted as a time zone" do
      it "returns a Barometer::Data::Zone" do
        subject.timezone = "PDT"
        subject.timezone.should be_a(Barometer::Data::Zone)
      end

      it "sets the value" do
        subject.timezone = "PDT"
        subject.timezone.code.should == "PDT"
      end

      it "clears the value" do
        subject.timezone = "MST"
        subject.timezone = nil
        subject.timezone.should be_nil
      end
    end

    context "when setting with Barometer::Data::Zone" do
      it "uses the passed in value" do
        timezone = Barometer::Data::Zone.new("PDT")
        subject.timezone = timezone
        subject.timezone.should be_a(Barometer::Data::Zone)
        subject.timezone.should == timezone
        subject.timezone.object_id.should == timezone.object_id
      end
    end
  end

  describe "boolean" do
    it { should respond_to :boolean }
    it { should respond_to :boolean= }

    context "when nothing has been set" do
      it "returns nil" do
        subject.boolean.should be_nil
        subject.should_not be_boolean
      end
    end

    context "when setting to nil" do
      it "returns nil" do
        subject.boolean = nil
        subject.boolean.should be_nil
        subject.should_not be_boolean
      end
    end

    context "when setting to anything truthy" do
      it "returns true" do
        subject.boolean = "PDT"
        subject.boolean.should be_true
        subject.should be_boolean

        subject.boolean = true
        subject.boolean.should be_true
        subject.should be_boolean

        subject.boolean = 0
        subject.boolean.should be_true
        subject.should be_boolean

        subject.boolean = []
        subject.boolean.should be_true
        subject.should be_boolean
      end
    end

    context "when setting to anything falsy (except nil)" do
      it "returns false" do
        subject.boolean = false
        subject.boolean.should be_false
        subject.should_not be_boolean
      end
    end
  end

end
