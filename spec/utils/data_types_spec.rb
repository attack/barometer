require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'virtus'

module Barometer
  class TestClass
    include Virtus
    include Utils::DataTypes

    attribute :location, Data::Attribute::Location
    attribute :timezone, Data::Attribute::Zone
    attribute :temperature, Data::Attribute::Temperature
    attribute :vector, Data::Attribute::Vector
    attribute :pressure, Data::Attribute::Pressure
    attribute :distance, Data::Attribute::Distance
    attribute :sun, Data::Attribute::Sun
    attribute :time, Data::Attribute::Time
  end

  describe Utils::DataTypes do
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

        it "clears the value" do
          subject.temperature = [12]
          subject.temperature = nil
          subject.temperature.should be_nil
        end
      end

      context "when setting with Barometer::Data::Temperature" do
        it "uses the passed in value" do
          temperature = Barometer::Data::Temperature.new(12)
          subject.temperature = temperature
          subject.temperature.should be_a(Barometer::Data::Temperature)
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

        it "clears the value" do
          subject.vector = [12]
          subject.vector = nil
          subject.vector.should be_nil
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

        it "clears the value" do
          subject.pressure = [12]
          subject.pressure = nil
          subject.pressure.should be_nil
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

        it "clears the value" do
          subject.distance = [42.2]
          subject.distance = nil
          subject.distance.should be_nil
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
          subject.time.should == Time.utc(2012, 10, 4, 5, 30, 45)
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
          subject.time.should == Time.utc(2012, 4, 10)
        end
      end

      context "when setting with Time" do
        it "uses the passed in value" do
          time = Time.now.utc
          subject.time = time
          subject.time.should be_a(Time)
          subject.time.should == time
        end
      end
    end

    describe "sun" do
      context "when setting to nil" do
        it "equals nil" do
          subject.sun = nil
          subject.sun.should be_nil
        end
      end

      context "when setting with pre-typed data" do
        it "accepts Data::Sun" do
          rise = Time.utc(2013, 02, 10, 5, 30, 45)
          set = Time.utc(2013, 02, 10, 17, 30, 45)
          sun = Barometer::Data::Sun.new(rise, set)

          subject.sun = sun

          subject.sun.should == sun
        end

        it "clears the value" do
          rise = Time.utc(2013, 02, 10, 6, 0, 0)
          set = Time.utc(2013, 02, 10, 6, 0, 0)
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

      context "when setting with Barometer::Data::Time" do
        it "uses the passed in value" do
          rise = Time.utc(2013, 02, 10, 6, 0, 0)
          set = Time.utc(2013, 02, 10, 6, 0, 0)
          sun = Barometer::Data::Sun.new(rise, set)
          subject.sun = sun
          subject.sun.should be_a(Barometer::Data::Sun)
          subject.sun.should == sun
          subject.sun.object_id.should == sun.object_id
        end
      end
    end

    describe "location" do
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
        it "sets the value" do
          location = Barometer::Data::Location.new(:name => 'foo')
          subject.location = location
          subject.location.to_s.should == "foo"
        end

        it "resets the value" do
          location = Barometer::Data::Location.new(:name => 'foo')
          subject.location = location

          subject.location = nil

          subject.location.to_s.should == ""
        end
      end
    end

    describe "timezone" do
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
        it "sets the value" do
          subject.timezone = Barometer::Data::Zone.new("PDT")
          subject.timezone.code.should == "PDT"
        end

        it "clears the value" do
          subject.timezone = Barometer::Data::Zone.new("MST")
          subject.timezone = nil
          subject.timezone.should be_nil
        end
      end
    end
  end
end
