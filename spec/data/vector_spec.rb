require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Vector do
  describe ".initialize" do
    it "sets kph" do
      vector = Barometer::Data::Vector.new(16.09, nil, nil)
      vector.kph.should == 16.09
    end

    it "sets mph" do
      vector = Barometer::Data::Vector.new(nil, 10, nil)
      vector.mph.should == 10
    end

    it "sets bearing" do
      vector = Barometer::Data::Vector.new(nil, nil, 270)
      vector.bearing.should == 270
    end

    describe "delays unit selection after init" do
      context "when initialized with kph and bearing only" do
        it "defaults to metric" do
          vector = Barometer::Data::Vector.new(20, 270)
          vector.to_s.should == "20 kph @ 270 degrees"
        end

        it "allows metric to be chosen after" do
          vector = Barometer::Data::Vector.new(20, 270)
          vector.metric = true
          vector.to_s.should == "20 kph @ 270 degrees"
        end

        it "sets the kph the first time, converts the second time" do
          vector = Barometer::Data::Vector.new(16.1, 270)
          vector.metric = true
          vector.metric = false
          vector.to_s.should == "10.0 mph @ 270 degrees"
        end
      end

      context "when initialized with mph and bearing only" do
        it "allows imperial to be chosen after" do
          vector = Barometer::Data::Vector.new(10, 270)
          vector.metric = false
          vector.to_s.should == "10 mph @ 270 degrees"
        end

        it "sets the mph the first time, converts the second time" do
          vector = Barometer::Data::Vector.new(10.0, 270)
          vector.metric = false
          vector.metric = true
          vector.to_s.should == "16.1 kph @ 270 degrees"
        end
      end
    end

    describe "sets unit type when given" do
      it "defaults to metric" do
        vector = Barometer::Data::Vector.new(nil, nil, nil)
        vector.should be_metric
      end

      it "sets metric via boolean" do
        vector = Barometer::Data::Vector.new(true, nil, nil, nil)
        vector.should be_metric
      end

      it "sets metric via symbol" do
        vector = Barometer::Data::Vector.new(:metric, nil, nil, nil)
        vector.should be_metric
      end

      it "sets imperial via boolean" do
        vector = Barometer::Data::Vector.new(false, nil, nil, nil)
        vector.should_not be_metric
      end

      it "sets imperial via symbol" do
        vector = Barometer::Data::Vector.new(:imperial, nil, nil, nil)
        vector.should_not be_metric
      end

      context "when only provided one magnitude" do
        context "and metric is set" do
          it "interprets magnitude as kph" do
            vector = Barometer::Data::Vector.new(:metric, 20, 270)
            vector.metric = false
            vector.metric = true
            vector.to_s.should == "20 kph @ 270 degrees"
          end
        end

        context "and imperial is set" do
          it "interprets magnitude as mph" do
            vector = Barometer::Data::Vector.new(:imperial, 10, 270)
            vector.metric = true
            vector.metric = false
            vector.to_s.should == "10 mph @ 270 degrees"
          end
        end
      end
    end
  end

  describe "#mph" do
    it "calculates mph from kph" do
      vector = Barometer::Data::Vector.new(16.09, nil, nil)
      vector.mph.should == 10.0
    end

    it "returns nil if mph is nil" do
      vector = Barometer::Data::Vector.new(nil, nil, nil)
      vector.mph.should be_nil
    end

    it "returns converted unknown value as mph" do
      vector = Barometer::Data::Vector.new(16, nil)
      vector.mph.should == 10
    end

    it "returns known value as mph" do
      vector = Barometer::Data::Vector.new(:imperial, 10, nil)
      vector.mph.should == 10
    end

    it "returns converted known value as mph" do
      vector = Barometer::Data::Vector.new(:metric, 16, nil)
      vector.mph.should == 10
    end

    # it "keeps integer resolution" do
    #   vector = Barometer::Data::Vector.new(:imperial, 10, nil)
    #   vector.kph.should == 16
    # end

    # it "keeps float resolution" do
    #   vector = Barometer::Data::Vector.new(:imperial, 10.0, nil)
    #   vector.kph.should == 16.1
    # end
  end

  describe "#kph" do
    it "calculates kph from mph" do
      vector = Barometer::Data::Vector.new(nil, 10, nil)
      vector.kph.should == 16.1
    end

    it "returns nil if mph is nil" do
      vector = Barometer::Data::Vector.new(nil, nil, nil)
      vector.kph.should be_nil
    end

    it "returns unknown value as kph" do
      vector = Barometer::Data::Vector.new(20, nil)
      vector.kph.should == 20
    end

    it "returns known value as kph" do
      vector = Barometer::Data::Vector.new(:metric, 20, nil)
      vector.kph.should == 20
    end

    it "returns converted known value as kph" do
      vector = Barometer::Data::Vector.new(:imperial, 10, nil)
      vector.kph.should == 16.1
    end

    # it "keeps integer resolution" do
    #   vector = Barometer::Data::Vector.new(:imperial, 10, nil)
    #   vector.kph.should == 16
    # end

    # it "keeps float resolution" do
    #   vector = Barometer::Data::Vector.new(:imperial, 10.0, nil)
    #   vector.kph.should == 16.1
    # end
  end

  describe "#<=>" do
    context "when comparing two metric vectors" do
      it "returns > correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 20, nil, nil)
        vector2 = Barometer::Data::Vector.new(:metric, 20.1, nil, nil)

        vector2.should > vector1
      end

      it "returns == correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 20, nil, nil)
        vector2 = Barometer::Data::Vector.new(:metric, 20.0, nil, nil)

        vector2.should == vector1
      end

      it "returns < correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 20, nil, nil)
        vector2 = Barometer::Data::Vector.new(:metric, 20.1, nil, nil)

        vector1.should < vector2
      end
    end

    context "when comparing two imperial vectors" do
      it "returns > correctly" do
        vector1 = Barometer::Data::Vector.new(:imperial, nil, 10, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.1, nil)

        vector2.should > vector1
      end

      it "returns == correctly" do
        vector1 = Barometer::Data::Vector.new(:imperial, nil, 10, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.0, nil)

        vector2.should == vector1
      end

      it "returns < correctly" do
        vector1 = Barometer::Data::Vector.new(:imperial, nil, 10, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.1, nil)

        vector1.should < vector2
      end
    end

    context "when comparing a mtric and an imperial vector" do
      it "returns > correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 16.0, nil, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.0, nil)

        vector2.should > vector1
      end

      it "returns == correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 16.1, nil, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.0, nil)

        vector2.should == vector1
      end

      it "returns < correctly" do
        vector1 = Barometer::Data::Vector.new(:metric, 16.2, nil, nil)
        vector2 = Barometer::Data::Vector.new(:imperial, nil, 10.0, nil)

        vector2.should < vector1
      end
    end
  end

  describe "#units" do
    context "when vector is metric" do
      it "returns kph" do
        vector = Barometer::Data::Vector.new(:metric, 20.0, 10.0, nil)
        vector.units.should == 'kph'
      end
    end

    context "when vector is imperial" do
      it "returns mph" do
        vector = Barometer::Data::Vector.new(:imperial, 20.0, 10.0, nil)
        vector.units.should == 'mph'
      end
    end
  end

  describe "#to_i" do
    context "when vector is metric" do
      it "returns the value of kph" do
        vector = Barometer::Data::Vector.new(:metric, 20.0, 10.0, nil)
        vector.to_i.should == 20
      end

      it "returns 0 if nothing is set" do
        vector = Barometer::Data::Vector.new(:metric, nil, nil, nil)
        vector.to_i.should == 0
      end
    end

    context "when vector is imperial" do
      it "returns the value of mph" do
        vector = Barometer::Data::Vector.new(:imperial, 20.0, 10.0, nil)
        vector.to_i.should == 10
      end

      it "returns 0 if nothing is set" do
        vector = Barometer::Data::Vector.new(:imperial, nil, nil, nil)
        vector.to_i.should == 0
      end
    end
  end

  describe "#to_f" do
    context "when vector is metric" do
      it "returns the value of kph" do
        vector = Barometer::Data::Vector.new(:metric, 20, 10, nil)
        vector.to_f.should == 20.0
      end

      it "returns 0 if nothing is set" do
        vector = Barometer::Data::Vector.new(:metric, nil, nil, nil)
        vector.to_f.should == 0.0
      end
    end

    context "when vector is imperial" do
      it "returns the value of mph" do
        vector = Barometer::Data::Vector.new(:imperial, 20, 10, nil)
        vector.to_f.should == 10.0
      end

      it "returns 0 if nothing is set" do
        vector = Barometer::Data::Vector.new(:imperial, nil, nil, nil)
        vector.to_f.should == 0.0
      end
    end
  end

  describe "#to_s" do
    context "when vector is metric" do
      it "returns kph only when no bearing" do
        vector = Barometer::Data::Vector.new(:metric, 16, nil, nil)
        vector.to_s.should == '16 kph'
      end

      it "returns bearing only when no kph" do
        vector = Barometer::Data::Vector.new(:metric, nil, nil, 270)
        vector.to_s.should == '270 degrees'
      end

      it "returns kph and bearing" do
        vector = Barometer::Data::Vector.new(:metric, 16, nil, 270)
        vector.to_s.should == '16 kph @ 270 degrees'
      end
    end

    context "when vector is imperial" do
      it "returns mph only when no bearing" do
        vector = Barometer::Data::Vector.new(:imperial, nil, 10, nil)
        vector.to_s.should == '10 mph'
      end

      it "returns bearing only when no mph" do
        vector = Barometer::Data::Vector.new(:imperial, nil, nil, 270)
        vector.to_s.should == '270 degrees'
      end

      it "returns mph and bearing" do
        vector = Barometer::Data::Vector.new(:imperial, nil, 10, 270)
        vector.to_s.should == '10 mph @ 270 degrees'
      end
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      vector = Barometer::Data::Vector.new(nil, nil, nil)
      vector.should be_nil
    end

    it "returns false if only kph set" do
      vector = Barometer::Data::Vector.new(20, nil, nil)
      vector.should_not be_nil
    end

    it "returns false if only mph set" do
      vector = Barometer::Data::Vector.new(nil, 10, nil)
      vector.should_not be_nil
    end

    it "returns false if only bearing set" do
      vector = Barometer::Data::Vector.new(nil, nil, 270)
      vector.should_not be_nil
    end
  end

  describe "#metric=" do
    context "when switching from :metric to :imperial" do
      it "becomes imperial using a boolean" do
        vector = Barometer::Data::Vector.new(:metric, 20, 10, nil)
        vector.metric = false

        vector.should_not be_metric
        vector.to_i.should == 10
      end

      it "becomes imperial using a symbol" do
        vector = Barometer::Data::Vector.new(:metric, 20, 10, nil)
        vector.metric = :imperial

        vector.should_not be_metric
        vector.to_i.should == 10
      end
    end

    context "when switching from :imperial to :metric" do
      it "becomes metric be default" do
        vector = Barometer::Data::Vector.new(:imperial, 20, 10, nil)
        vector.metric = nil

        vector.should be_metric
        vector.to_i.should == 20
      end

      it "becomes metric using a boolean" do
        vector = Barometer::Data::Vector.new(:imperial, 20, 10, nil)
        vector.metric = true

        vector.should be_metric
        vector.to_i.should == 20
      end

      it "becomes metric using a symbol" do
        vector = Barometer::Data::Vector.new(:imperial, 20, 10, nil)
        vector.metric = :metric

        vector.should be_metric
        vector.to_i.should == 20
      end
    end
  end
end
