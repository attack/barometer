require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Temperature do
  describe ".initialize" do
    it "sets C" do
      temperature = Barometer::Data::Temperature.new(20.0, nil)
      temperature.c.should == 20.0
    end

    it "sets F" do
      temperature = Barometer::Data::Temperature.new(nil, 68.0)
      temperature.f.should == 68.0
    end

    describe "delays unit selection after init" do
      context "when initialized with C only" do
        it "defaults to metric" do
          temperature = Barometer::Data::Temperature.new(20)
          temperature.to_s.should == "20 C"
        end

        it "allows metric to be chosen after" do
          temperature = Barometer::Data::Temperature.new(20)
          temperature.metric = true
          temperature.to_s.should == "20 C"
        end

        it "sets the C the first time, converts the second time" do
          temperature = Barometer::Data::Temperature.new(20.0)
          temperature.metric = true
          temperature.metric = false
          temperature.to_s.should == "68.0 F"
        end
      end

      context "when initialized with F only" do
        it "allows imperial to be chosen after" do
          temperature = Barometer::Data::Temperature.new(68)
          temperature.metric = false
          temperature.to_s.should == "68 F"
        end

        it "sets the m the first time, converts the second time" do
          temperature = Barometer::Data::Temperature.new(68.0)
          temperature.metric = false
          temperature.metric = true
          temperature.to_s.should == "20.0 C"
        end
      end
    end

    describe "sets unit type when given" do
      it "defaults to metric" do
        temperature = Barometer::Data::Temperature.new(nil, nil)
        temperature.should be_metric
      end

      it "sets metric via boolean" do
        temperature = Barometer::Data::Temperature.new(true, nil, nil)
        temperature.should be_metric
      end

      it "sets metric via symbol" do
        temperature = Barometer::Data::Temperature.new(:metric, nil, nil)
        temperature.should be_metric
      end

      it "sets imperial via boolean" do
        temperature = Barometer::Data::Temperature.new(false, nil, nil)
        temperature.should_not be_metric
      end

      it "sets imperial via symbol" do
        temperature = Barometer::Data::Temperature.new(:imperial, nil, nil)
        temperature.should_not be_metric
      end

      context "when only provided one magnitude" do
        context "and metric is set" do
          it "interprets magnitude as C" do
            temperature = Barometer::Data::Temperature.new(:metric, 20)
            temperature.metric = false
            temperature.metric = true
            temperature.to_s.should == "20 C"
          end
        end

        context "and imperial is set" do
          it "interprets magnitude as m" do
            temperature = Barometer::Data::Temperature.new(:imperial, 68)
            temperature.metric = true
            temperature.metric = false
            temperature.to_s.should == "68 F"
          end
        end
      end
    end
  end

  describe "#m" do
    it "calculates m from C" do
      temperature = Barometer::Data::Temperature.new(20.0, nil)
      temperature.f.should == 68.0
    end

    it "returns nil if F is nil" do
      temperature = Barometer::Data::Temperature.new(nil, nil)
      temperature.f.should be_nil
    end

    it "returns converted unknown value as F" do
      temperature = Barometer::Data::Temperature.new(20.0)
      temperature.f.should == 68.0
    end

    it "returns known value as F" do
      temperature = Barometer::Data::Temperature.new(:imperial, 68)
      temperature.f.should == 68
    end

    it "returns converted known value as F" do
      temperature = Barometer::Data::Temperature.new(:metric, 20.0)
      temperature.f.should == 68.0
    end

    # it "keeps integer resolution" do
    #   temperature = Barometer::Data::Temperature.new(:imperial, 10)
    #   temperature.c.should == 16
    # end

    # it "keeps float resolution" do
    #   temperature = Barometer::Data::Temperature.new(:imperial, 10.0)
    #   temperature.c.should == 16.1
    # end
  end

  describe "#c" do
    it "calculates C from F" do
      temperature = Barometer::Data::Temperature.new(nil, 68.0)
      temperature.c.should == 20.0
    end

    it "returns nil if F is nil" do
      temperature = Barometer::Data::Temperature.new(nil, nil)
      temperature.c.should be_nil
    end

    it "returns unknown value as C" do
      temperature = Barometer::Data::Temperature.new(20)
      temperature.c.should == 20
    end

    it "returns known value as C" do
      temperature = Barometer::Data::Temperature.new(:metric, 20)
      temperature.c.should == 20
    end

    it "returns converted known value as C" do
      temperature = Barometer::Data::Temperature.new(:imperial, 68.0)
      temperature.c.should == 20.0
    end

    # it "keeps integer resolution" do
    #   temperature = Barometer::Data::Temperature.new(:imperial, 10)
    #   temperature.c.should == 16
    # end

    # it "keeps float resolution" do
    #   temperature = Barometer::Data::Temperature.new(:imperial, 10.0)
    #   temperature.c.should == 16.1
    # end
  end

  describe "#<=>" do
    context "when comparing two metric temperatures" do
      it "returns > correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20, nil)
        temperature2 = Barometer::Data::Temperature.new(:metric, 20.2, nil)

        temperature2.should > temperature1
      end

      it "returns == correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20, nil)
        temperature2 = Barometer::Data::Temperature.new(:metric, 20.0, nil)

        temperature2.should == temperature1
      end

      it "returns < correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20, nil)
        temperature2 = Barometer::Data::Temperature.new(:metric, 20.2, nil)

        temperature1.should < temperature2
      end
    end

    context "when comparing two imperial temperatures" do
      it "returns > correctly" do
        temperature1 = Barometer::Data::Temperature.new(:imperial, nil, 68)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.2)

        temperature2.should > temperature1
      end

      it "returns == correctly" do
        temperature1 = Barometer::Data::Temperature.new(:imperial, nil, 68)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.0)

        temperature2.should == temperature1
      end

      it "returns < correctly" do
        temperature1 = Barometer::Data::Temperature.new(:imperial, nil, 68)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.2)

        temperature1.should < temperature2
      end
    end

    context "when comparing a mtric and an imperial temperature" do
      it "returns > correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20.0, nil)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.2)

        temperature2.should > temperature1
      end

      it "returns == correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20.0, nil)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.0)

        temperature2.should == temperature1
      end

      it "returns < correctly" do
        temperature1 = Barometer::Data::Temperature.new(:metric, 20.3, nil)
        temperature2 = Barometer::Data::Temperature.new(:imperial, nil, 68.0)

        temperature2.should < temperature1
      end
    end
  end

  describe "#units" do
    context "when temperature is metric" do
      it "returns C" do
        temperature = Barometer::Data::Temperature.new(:metric, 20.0, 68.0)
        temperature.units.should == 'C'
      end
    end

    context "when temperature is imperial" do
      it "returns F" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20.0, 68.0)
        temperature.units.should == 'F'
      end
    end
  end

  describe "#to_i" do
    context "when temperature is metric" do
      it "returns the value of C" do
        temperature = Barometer::Data::Temperature.new(:metric, 20.0, 68.0)
        temperature.to_i.should == 20
      end

      it "returns 0 if nothing is set" do
        temperature = Barometer::Data::Temperature.new(:metric, nil, nil)
        temperature.to_i.should == 0
      end
    end

    context "when temperature is imperial" do
      it "returns the value of F" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20.0, 68.0)
        temperature.to_i.should == 68
      end

      it "returns 0 if nothing is set" do
        temperature = Barometer::Data::Temperature.new(:imperial, nil, nil)
        temperature.to_i.should == 0
      end
    end
  end

  describe "#to_f" do
    context "when temperature is metric" do
      it "returns the value of C" do
        temperature = Barometer::Data::Temperature.new(:metric, 20, 68)
        temperature.to_f.should == 20.0
      end

      it "returns 0 if nothing is set" do
        temperature = Barometer::Data::Temperature.new(:metric, nil, nil)
        temperature.to_f.should == 0.0
      end
    end

    context "when temperature is imperial" do
      it "returns the value of F" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20, 68)
        temperature.to_f.should == 68.0
      end

      it "returns 0 if nothing is set" do
        temperature = Barometer::Data::Temperature.new(:imperial, nil, nil)
        temperature.to_f.should == 0.0
      end
    end
  end

  describe "#to_s" do
    context "when temperature is metric" do
      it "returns C" do
        temperature = Barometer::Data::Temperature.new(:metric, 20, nil)
        temperature.to_s.should == '20 C'
      end
    end

    context "when temperature is imperial" do
      it "returns F" do
        temperature = Barometer::Data::Temperature.new(:imperial, nil, 68)
        temperature.to_s.should == '68 F'
      end
    end
  end

  describe "#nil?" do
    it "returns true if nothing is set" do
      temperature = Barometer::Data::Temperature.new(nil, nil)
      temperature.should be_nil
    end

    it "returns false if only C set" do
      temperature = Barometer::Data::Temperature.new(20, nil)
      temperature.should_not be_nil
    end

    it "returns false if only F set" do
      temperature = Barometer::Data::Temperature.new(nil, 68)
      temperature.should_not be_nil
    end
  end

  describe "#metric=" do
    context "when switching from :metric to :imperial" do
      it "becomes imperial using a boolean" do
        temperature = Barometer::Data::Temperature.new(:metric, 20, 68)
        temperature.metric = false

        temperature.should_not be_metric
        temperature.to_i.should == 68
      end

      it "becomes imperial using a symbol" do
        temperature = Barometer::Data::Temperature.new(:metric, 20, 68)
        temperature.metric = :imperial

        temperature.should_not be_metric
        temperature.to_i.should == 68
      end
    end

    context "when switching from :imperial to :metric" do
      it "becomes metric be default" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20, 68)
        temperature.metric = nil

        temperature.should be_metric
        temperature.to_i.should == 20
      end

      it "becomes metric using a boolean" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20, 68)
        temperature.metric = true

        temperature.should be_metric
        temperature.to_i.should == 20
      end

      it "becomes metric using a symbol" do
        temperature = Barometer::Data::Temperature.new(:imperial, 20, 68)
        temperature.metric = :metric

        temperature.should be_metric
        temperature.to_i.should == 20
      end
    end
  end
end
