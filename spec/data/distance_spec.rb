require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Distance do
  describe ".initialize" do
    it "sets km" do
      distance = Barometer::Data::Distance.new(42.2, nil)
      distance.km.should == 42.2
    end

    it "sets m" do
      distance = Barometer::Data::Distance.new(nil, 26.2)
      distance.m.should == 26.2
    end

    describe "delays unit selection after init" do
      context "when initialized with km only" do
        it "defaults to metric" do
          distance = Barometer::Data::Distance.new(42)
          distance.to_s.should == "42 km"
        end

        it "allows metric to be chosen after" do
          distance = Barometer::Data::Distance.new(42)
          distance.metric = true
          distance.to_s.should == "42 km"
        end

        it "sets the km the first time, converts the second time" do
          distance = Barometer::Data::Distance.new(42.2)
          distance.metric = true
          distance.metric = false
          distance.to_s.should == "26.2 m"
        end
      end

      context "when initialized with m only" do
        it "allows imperial to be chosen after" do
          distance = Barometer::Data::Distance.new(26)
          distance.metric = false
          distance.to_s.should == "26 m"
        end

        it "sets the m the first time, converts the second time" do
          distance = Barometer::Data::Distance.new(26.2)
          distance.metric = false
          distance.metric = true
          distance.to_s.should == "42.2 km"
        end
      end
    end

    describe "sets unit type when given" do
      it "defaults to metric" do
        distance = Barometer::Data::Distance.new(nil, nil)
        distance.should be_metric
      end

      it "sets metric via boolean" do
        distance = Barometer::Data::Distance.new(true, nil, nil)
        distance.should be_metric
      end

      it "sets metric via symbol" do
        distance = Barometer::Data::Distance.new(:metric, nil, nil)
        distance.should be_metric
      end

      it "sets imperial via boolean" do
        distance = Barometer::Data::Distance.new(false, nil, nil)
        distance.should_not be_metric
      end

      it "sets imperial via symbol" do
        distance = Barometer::Data::Distance.new(:imperial, nil, nil)
        distance.should_not be_metric
      end

      context "when only provided one magnitude" do
        context "and metric is set" do
          it "interprets magnitude as km" do
            distance = Barometer::Data::Distance.new(:metric, 42)
            distance.metric = false
            distance.metric = true
            distance.to_s.should == "42 km"
          end
        end

        context "and imperial is set" do
          it "interprets magnitude as m" do
            distance = Barometer::Data::Distance.new(:imperial, 26)
            distance.metric = true
            distance.metric = false
            distance.to_s.should == "26 m"
          end
        end
      end
    end
  end

  describe "#m" do
    it "calculates m from km" do
      distance = Barometer::Data::Distance.new(42.2, nil)
      distance.m.should == 26.2
    end

    it "returns nil if m is nil" do
      distance = Barometer::Data::Distance.new(nil, nil)
      distance.m.should be_nil
    end

    it "returns converted unknown value as m" do
      distance = Barometer::Data::Distance.new(42.2)
      distance.m.should == 26.2
    end

    it "returns known value as m" do
      distance = Barometer::Data::Distance.new(:imperial, 26)
      distance.m.should == 26
    end

    it "returns converted known value as m" do
      distance = Barometer::Data::Distance.new(:metric, 42.2)
      distance.m.should == 26.2
    end

    # it "keeps integer resolution" do
    #   distance = Barometer::Data::Distance.new(:imperial, 10)
    #   distance.km.should == 16
    # end

    # it "keeps float resolution" do
    #   distance = Barometer::Data::Distance.new(:imperial, 10.0)
    #   distance.km.should == 16.1
    # end
  end

  describe "#km" do
    it "calculates km from m" do
      distance = Barometer::Data::Distance.new(nil, 26.2)
      distance.km.should == 42.2
    end

    it "returns nil if m is nil" do
      distance = Barometer::Data::Distance.new(nil, nil)
      distance.km.should be_nil
    end

    it "returns unknown value as km" do
      distance = Barometer::Data::Distance.new(42)
      distance.km.should == 42
    end

    it "returns known value as km" do
      distance = Barometer::Data::Distance.new(:metric, 42)
      distance.km.should == 42
    end

    it "returns converted known value as km" do
      distance = Barometer::Data::Distance.new(:imperial, 26.2)
      distance.km.should == 42.2
    end

    # it "keeps integer resolution" do
    #   distance = Barometer::Data::Distance.new(:imperial, 10)
    #   distance.km.should == 16
    # end

    # it "keeps float resolution" do
    #   distance = Barometer::Data::Distance.new(:imperial, 10.0)
    #   distance.km.should == 16.1
    # end
  end

  describe "#<=>" do
    context "when comparing two metric distances" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42, nil)
        distance2 = Barometer::Data::Distance.new(:metric, 42.2, nil)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42, nil)
        distance2 = Barometer::Data::Distance.new(:metric, 42.0, nil)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42, nil)
        distance2 = Barometer::Data::Distance.new(:metric, 42.2, nil)

        distance1.should < distance2
      end
    end

    context "when comparing two imperial distances" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Distance.new(:imperial, nil, 26)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.2)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Distance.new(:imperial, nil, 26)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.0)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Distance.new(:imperial, nil, 26)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.2)

        distance1.should < distance2
      end
    end

    context "when comparing a mtric and an imperial distance" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42.0, nil)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.2)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42.2, nil)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.2)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Distance.new(:metric, 42.3, nil)
        distance2 = Barometer::Data::Distance.new(:imperial, nil, 26.2)

        distance2.should < distance1
      end
    end
  end

  describe "#units" do
    context "when distance is metric" do
      it "returns km" do
        distance = Barometer::Data::Distance.new(:metric, 42.0, 26.0)
        distance.units.should == 'km'
      end
    end

    context "when distance is imperial" do
      it "returns m" do
        distance = Barometer::Data::Distance.new(:imperial, 42.0, 26.0)
        distance.units.should == 'm'
      end
    end
  end

  describe "#to_i" do
    context "when distance is metric" do
      it "returns the value of km" do
        distance = Barometer::Data::Distance.new(:metric, 42.0, 26.0)
        distance.to_i.should == 42
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Distance.new(:metric, nil, nil)
        distance.to_i.should == 0
      end
    end

    context "when distance is imperial" do
      it "returns the value of m" do
        distance = Barometer::Data::Distance.new(:imperial, 42.0, 26.0)
        distance.to_i.should == 26
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Distance.new(:imperial, nil, nil)
        distance.to_i.should == 0
      end
    end
  end

  describe "#to_f" do
    context "when distance is metric" do
      it "returns the value of km" do
        distance = Barometer::Data::Distance.new(:metric, 42, 26)
        distance.to_f.should == 42.0
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Distance.new(:metric, nil, nil)
        distance.to_f.should == 0.0
      end
    end

    context "when distance is imperial" do
      it "returns the value of m" do
        distance = Barometer::Data::Distance.new(:imperial, 42, 26)
        distance.to_f.should == 26.0
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Distance.new(:imperial, nil, nil)
        distance.to_f.should == 0.0
      end
    end
  end

  describe "#to_s" do
    context "when distance is metric" do
      it "returns km" do
        distance = Barometer::Data::Distance.new(:metric, 42, nil)
        distance.to_s.should == '42 km'
      end
    end

    context "when distance is imperial" do
      it "returns m" do
        distance = Barometer::Data::Distance.new(:imperial, nil, 26)
        distance.to_s.should == '26 m'
      end
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      distance = Barometer::Data::Distance.new(nil, nil)
      distance.should be_nil
    end

    it "returns false if only km set" do
      distance = Barometer::Data::Distance.new(42, nil)
      distance.should_not be_nil
    end

    it "returns false if only m set" do
      distance = Barometer::Data::Distance.new(nil, 26)
      distance.should_not be_nil
    end
  end

  describe "#metric=" do
    context "when switching from :metric to :imperial" do
      it "becomes imperial using a boolean" do
        distance = Barometer::Data::Distance.new(:metric, 42, 26)
        distance.metric = false

        distance.should_not be_metric
        distance.to_i.should == 26
      end

      it "becomes imperial using a symbol" do
        distance = Barometer::Data::Distance.new(:metric, 42, 26)
        distance.metric = :imperial

        distance.should_not be_metric
        distance.to_i.should == 26
      end
    end

    context "when switching from :imperial to :metric" do
      it "becomes metric be default" do
        distance = Barometer::Data::Distance.new(:imperial, 42, 26)
        distance.metric = nil

        distance.should be_metric
        distance.to_i.should == 42
      end

      it "becomes metric using a boolean" do
        distance = Barometer::Data::Distance.new(:imperial, 42, 26)
        distance.metric = true

        distance.should be_metric
        distance.to_i.should == 42
      end

      it "becomes metric using a symbol" do
        distance = Barometer::Data::Distance.new(:imperial, 42, 26)
        distance.metric = :metric

        distance.should be_metric
        distance.to_i.should == 42
      end
    end
  end
end
