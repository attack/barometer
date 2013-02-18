require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestClass
  include Barometer::DataTypes

  temperature :temperature
  vector :vector
  pressure :pressure
  distance :distance
  number :number
  string :string
  local_datetime :local_datetime
  local_time :local_time
  sun :sun
end

describe Barometer::DataTypes do
  subject { TestClass.new }

  describe "temperature" do
    it { should respond_to :temperature }
    it { should respond_to :temperature= }

    context "when setting to nil" do
      it "equals nil" do
        subject.temperature = nil
        subject.temperature.should be_nil
      end

      it "prints nothing" do
        subject.temperature = nil
        subject.temperature.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::Temperature" do
        subject.temperature = 12
        subject.temperature.should be_a(Data::Temperature)
      end

      it "prints correctly" do
        subject.temperature = 12
        subject.temperature.to_s.should == "12 C"
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
      it "initializes Data::Vector" do
        subject.vector = 12
        subject.vector.should be_a(Data::Vector)
      end

      it "prints correctly" do
        subject.vector = 12
        subject.vector.to_s.should == "12 kph"
      end
    end

    context "when setting secondary values" do
      it "allows the setting of direction" do
        subject.vector = 12
        subject.vector.direction = "NW"
        subject.vector.to_s.should == "12 kph NW"
      end

      it "allows the setting of degrees" do
        subject.vector = 12
        subject.vector.degrees = 190
        subject.vector.to_s.should == "12 kph @ 190 degrees"
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

      it "prints nothing" do
        subject.pressure = nil
        subject.pressure.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::Pressure" do
        subject.pressure = 12
        subject.pressure.should be_a(Data::Pressure)
      end

      it "prints correctly" do
        subject.pressure = 12
        subject.pressure.to_s.should == "12 mb"
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

      it "prints nothing" do
        subject.distance = nil
        subject.distance.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::Distance" do
        subject.distance = 12
        subject.distance.should be_a(Data::Distance)
      end

      it "prints correctly" do
        subject.distance = 12
        subject.distance.to_s.should == "12 km"
      end
    end
  end

  describe "number" do
    it { should respond_to :number }
    it { should respond_to :number= }

    context "when setting to nil" do
      it "equals nil" do
        subject.number = nil
        subject.number.should be_nil
      end

      it "prints nothing" do
        subject.number = nil
        subject.number.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Numeric" do
        subject.number = "12 cats"
        subject.number.should be_a(Numeric)
      end

      it "prints correctly" do
        subject.number = "12 cats"
        subject.number.to_s.should == "12.0"
      end
    end
  end

  describe "string" do
    it { should respond_to :string }
    it { should respond_to :string= }

    context "when setting to nil" do
      it "equals nil" do
        subject.string = nil
        subject.string.should be_nil
      end

      it "prints nothing" do
        subject.string = nil
        subject.string.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes String" do
        subject.string = 12
        subject.string.should be_a(String)
      end

      it "prints correctly" do
        subject.string = 12
        subject.string.to_s.should == "12"
      end
    end
  end

  describe "local_datatime" do
    it { should respond_to :local_datetime }
    it { should respond_to :local_datetime= }

    context "when setting to nil" do
      it "equals nil" do
        subject.local_datetime = nil
        subject.local_datetime.should be_nil
      end

      it "prints nothing" do
        subject.local_datetime = nil
        subject.local_datetime.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::LocalDateTime" do
        subject.local_datetime = 2012, 10, 4, 5, 30, 45
        subject.local_datetime.should == Data::LocalDateTime.new(2012, 10, 4, 5, 30, 45)
      end

      it "prints correctly" do
        subject.local_datetime = 2012, 10, 4, 5, 30, 45
        subject.local_datetime.to_s(true).should == "2012-10-04 05:30:45 am"
      end
    end

    context "when setting with data to parse" do
      it "initializes Data::LocalDateTime" do
        subject.local_datetime = "2012-10-4 5:30:45 pm"
        subject.local_datetime.should == Data::LocalDateTime.new(2012, 10, 4, 17, 30, 45)
      end

      it "prints correctly" do
        subject.local_datetime = "2012-10-4 5:30:45 pm"
        subject.local_datetime.to_s(true).should == "2012-10-04 05:30:45 pm"
      end
    end

    context "when setting with data to parse (including format)" do
      it "initializes Data::LocalDateTime" do
        subject.local_datetime = "2012-10-4", "%Y-%d-%m"
        subject.local_datetime.should == Data::LocalDateTime.new(2012, 4, 10)
      end

      it "prints correctly" do
        subject.local_datetime = "2012-10-4", "%Y-%d-%m"
        subject.local_datetime.to_s.should == "2012-04-10"
      end
    end
  end

  describe "local_time" do
    it { should respond_to :local_time }
    it { should respond_to :local_time= }

    context "when setting to nil" do
      it "equals nil" do
        subject.local_time = nil
        subject.local_time.should be_nil
      end

      it "prints nothing" do
        subject.local_time = nil
        subject.local_time.to_s.should == ""
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::LocalTime" do
        subject.local_time = 5, 30, 45
        subject.local_time.should == Data::LocalTime.new(5, 30, 45)
      end

      it "prints correctly" do
        subject.local_time = 5, 30, 45
        subject.local_time.to_s(true).should == "05:30:45 am"
      end
    end

    context "when setting with data to parse" do
      it "initializes Data::LocalTime" do
        subject.local_time = "5:30:45 pm"
        subject.local_time.should == Data::LocalTime.new(17, 30, 45)
      end

      it "prints correctly" do
        subject.local_time = "5:30:45 pm"
        subject.local_time.to_s(true).should == "05:30:45 pm"
      end
    end
  end

  describe "sun" do
    it { should respond_to :sun }
    it { should_not respond_to :sun= }

    context "when setting to nil" do
      it "equals nil" do
        subject.sun.rise = nil
        subject.sun.set = nil
        subject.sun.should be_nil
      end
    end

    context "when setting with data of exact values" do
      it "initializes Data::Sun" do
        rise = Data::LocalTime.new(5, 30, 45)
        subject.sun.rise = rise

        set = Data::LocalTime.new(17, 30, 45)
        subject.sun.set = set

        subject.sun.rise.should == rise
        subject.sun.set.should == set
      end
    end
  end
end
