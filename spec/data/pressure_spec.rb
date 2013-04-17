require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

    # For all conversions
    # 721.64 mb = 21.31 in
    # before(:each) do
    #   @in = 21.31
    #   @mb = 721.64 (metric)
    # end
    # it "responds to millibars" do
    # it "responds to inches" do
describe Barometer::Data::Pressure do
  describe ".initialize" do
    it "sets mb" do
      distance = Barometer::Data::Pressure.new(721.64, nil)
      distance.mb.should == 721.64
    end

    it "sets in" do
      distance = Barometer::Data::Pressure.new(nil, 21.31)
      distance.in.should == 21.31
    end

    describe "delays unit selection after init" do
      context "when initialized with mb only" do
        it "defaults to metric" do
          distance = Barometer::Data::Pressure.new(721)
          distance.to_s.should == "721 mb"
        end

        it "allows metric to be chosen after" do
          distance = Barometer::Data::Pressure.new(721)
          distance.metric = true
          distance.to_s.should == "721 mb"
        end

        it "sets the mb the first time, converts the second time" do
          distance = Barometer::Data::Pressure.new(721.64)
          distance.metric = true
          distance.metric = false
          distance.to_s.should == "21.3 in"
        end
      end

      context "when initialized with in only" do
        it "allows imperial to be chosen after" do
          distance = Barometer::Data::Pressure.new(21)
          distance.metric = false
          distance.to_s.should == "21 in"
        end

        it "sets the m the first time, converts the second time" do
          distance = Barometer::Data::Pressure.new(21.31)
          distance.metric = false
          distance.metric = true
          distance.to_s.should == "721.6 mb"
        end
      end
    end

    describe "sets unit type when given" do
      it "defaults to metric" do
        distance = Barometer::Data::Pressure.new(nil, nil)
        distance.should be_metric
      end

      it "sets metric via boolean" do
        distance = Barometer::Data::Pressure.new(true, nil, nil)
        distance.should be_metric
      end

      it "sets metric via symbol" do
        distance = Barometer::Data::Pressure.new(:metric, nil, nil)
        distance.should be_metric
      end

      it "sets imperial via boolean" do
        distance = Barometer::Data::Pressure.new(false, nil, nil)
        distance.should_not be_metric
      end

      it "sets imperial via symbol" do
        distance = Barometer::Data::Pressure.new(:imperial, nil, nil)
        distance.should_not be_metric
      end

      context "when only provided one magnitude" do
        context "and metric is set" do
          it "interprets magnitude as mb" do
            distance = Barometer::Data::Pressure.new(:metric, 721)
            distance.metric = false
            distance.metric = true
            distance.to_s.should == "721 mb"
          end
        end

        context "and imperial is set" do
          it "interprets magnitude as in" do
            distance = Barometer::Data::Pressure.new(:imperial, 21)
            distance.metric = true
            distance.metric = false
            distance.to_s.should == "21 in"
          end
        end
      end
    end
  end

  describe "#in" do
    it "calculates in from mb" do
      distance = Barometer::Data::Pressure.new(721.64, nil)
      distance.in.should == 21.3
    end

    it "returns nil if in is nil" do
      distance = Barometer::Data::Pressure.new(nil, nil)
      distance.in.should be_nil
    end

    it "returns converted unknown value as in" do
      distance = Barometer::Data::Pressure.new(721.64)
      distance.in.should == 21.3
    end

    it "returns known value as in" do
      distance = Barometer::Data::Pressure.new(:imperial, 21)
      distance.in.should == 21
    end

    it "returns converted known value as in" do
      distance = Barometer::Data::Pressure.new(:metric, 721.64)
      distance.in.should == 21.3
    end

    # it "keeps integer resolution" do
    #   distance = Barometer::Data::Pressure.new(:imperial, 10)
    #   distance.mb.should == 16
    # end

    # it "keeps float resolution" do
    #   distance = Barometer::Data::Pressure.new(:imperial, 10.0)
    #   distance.mb.should == 16.1
    # end
  end

  describe "#mb" do
    it "calculates mb from in" do
      distance = Barometer::Data::Pressure.new(nil, 21.31)
      distance.mb.should == 721.6
    end

    it "returns nil if in is nil" do
      distance = Barometer::Data::Pressure.new(nil, nil)
      distance.mb.should be_nil
    end

    it "returns unknown value as mb" do
      distance = Barometer::Data::Pressure.new(721)
      distance.mb.should == 721
    end

    it "returns known value as mb" do
      distance = Barometer::Data::Pressure.new(:metric, 721)
      distance.mb.should == 721
    end

    it "returns converted known value as mb" do
      distance = Barometer::Data::Pressure.new(:imperial, 21.31)
      distance.mb.should == 721.6
    end

    # it "keeps integer resolution" do
    #   distance = Barometer::Data::Pressure.new(:imperial, 10)
    #   distance.mb.should == 16
    # end

    # it "keeps float resolution" do
    #   distance = Barometer::Data::Pressure.new(:imperial, 10.0)
    #   distance.mb.should == 16.1
    # end
  end

  describe "#<=>" do
    context "when comparing two metric distances" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721, nil)
        distance2 = Barometer::Data::Pressure.new(:metric, 721.64, nil)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721, nil)
        distance2 = Barometer::Data::Pressure.new(:metric, 721.0, nil)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721, nil)
        distance2 = Barometer::Data::Pressure.new(:metric, 721.64, nil)

        distance1.should < distance2
      end
    end

    context "when comparing two imperial distances" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Pressure.new(:imperial, nil, 21)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.31)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Pressure.new(:imperial, nil, 21)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.0)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Pressure.new(:imperial, nil, 21)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.31)

        distance1.should < distance2
      end
    end

    context "when comparing a metric and an imperial distance" do
      it "returns > correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721.0, nil)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.31)

        distance2.should > distance1
      end

      it "returns == correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721.64, nil)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.31)

        distance2.should == distance1
      end

      it "returns < correctly" do
        distance1 = Barometer::Data::Pressure.new(:metric, 721.9, nil)
        distance2 = Barometer::Data::Pressure.new(:imperial, nil, 21.31)

        distance2.should < distance1
      end
    end
  end

  describe "#units" do
    context "when distance is metric" do
      it "returns mb" do
        distance = Barometer::Data::Pressure.new(:metric, 721.0, 21.0)
        distance.units.should == 'mb'
      end
    end

    context "when distance is imperial" do
      it "returns in" do
        distance = Barometer::Data::Pressure.new(:imperial, 721.0, 21.0)
        distance.units.should == 'in'
      end
    end
  end

  describe "#to_i" do
    context "when distance is metric" do
      it "returns the value of mb" do
        distance = Barometer::Data::Pressure.new(:metric, 721.0, 21.0)
        distance.to_i.should == 721
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Pressure.new(:metric, nil, nil)
        distance.to_i.should == 0
      end
    end

    context "when distance is imperial" do
      it "returns the value of in" do
        distance = Barometer::Data::Pressure.new(:imperial, 721.0, 21.0)
        distance.to_i.should == 21
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Pressure.new(:imperial, nil, nil)
        distance.to_i.should == 0
      end
    end
  end

  describe "#to_f" do
    context "when distance is metric" do
      it "returns the value of mb" do
        distance = Barometer::Data::Pressure.new(:metric, 721, 21)
        distance.to_f.should == 721.0
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Pressure.new(:metric, nil, nil)
        distance.to_f.should == 0.0
      end
    end

    context "when distance is imperial" do
      it "returns the value of in" do
        distance = Barometer::Data::Pressure.new(:imperial, 721, 21)
        distance.to_f.should == 21.0
      end

      it "returns 0 if nothing is set" do
        distance = Barometer::Data::Pressure.new(:imperial, nil, nil)
        distance.to_f.should == 0.0
      end
    end
  end

  describe "#to_s" do
    context "when distance is metric" do
      it "returns mb" do
        distance = Barometer::Data::Pressure.new(:metric, 721, nil)
        distance.to_s.should == '721 mb'
      end
    end

    context "when distance is imperial" do
      it "returns in" do
        distance = Barometer::Data::Pressure.new(:imperial, nil, 21)
        distance.to_s.should == '21 in'
      end
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      distance = Barometer::Data::Pressure.new(nil, nil)
      distance.should be_nil
    end

    it "returns false if only mb set" do
      distance = Barometer::Data::Pressure.new(721, nil)
      distance.should_not be_nil
    end

    it "returns false if only in set" do
      distance = Barometer::Data::Pressure.new(nil, 21)
      distance.should_not be_nil
    end
  end

  describe "#metric=" do
    context "when switching from :metric to :imperial" do
      it "becomes imperial using a boolean" do
        distance = Barometer::Data::Pressure.new(:metric, 721, 21)
        distance.metric = false

        distance.should_not be_metric
        distance.to_i.should == 21
      end

      it "becomes imperial using a symbol" do
        distance = Barometer::Data::Pressure.new(:metric, 721, 21)
        distance.metric = :imperial

        distance.should_not be_metric
        distance.to_i.should == 21
      end
    end

    context "when switching from :imperial to :metric" do
      it "becomes metric be default" do
        distance = Barometer::Data::Pressure.new(:imperial, 721, 21)
        distance.metric = nil

        distance.should be_metric
        distance.to_i.should == 721
      end

      it "becomes metric using a boolean" do
        distance = Barometer::Data::Pressure.new(:imperial, 721, 21)
        distance.metric = true

        distance.should be_metric
        distance.to_i.should == 721
      end

      it "becomes metric using a symbol" do
        distance = Barometer::Data::Pressure.new(:imperial, 721, 21)
        distance.metric = :metric

        distance.should be_metric
        distance.to_i.should == 721
      end
    end
  end
end
