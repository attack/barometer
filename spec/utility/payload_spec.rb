require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Payload do
  describe "#fetch" do
    it "returns the value for the key provided" do
      hash = {:one => 1}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one).should == 1
    end

    it "returns nil when the key cannot be found" do
      hash = {}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one).should be_nil
    end

    it "traverses multiple levels to get the value" do
      hash = {:one => {:two => {:three => 3}}}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one, :two, :three).should == 3
    end

    it "returns nil when any level cannot be found" do
      hash = {:one => {:two => {:three => {:four => 4}}}}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one, :too, :three).should be_nil
    end

    it "returns nil when the starting value is nil" do
      hash = nil
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one).should be_nil
    end

    it "returns a stripped result" do
      hash = {:one => " one "}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one).should == "one"
    end

    it "returns nil when the value is NA" do
      hash = {:one => "NA"}
      parser = Barometer::Payload.new(hash)
      parser.fetch(:one).should be_nil
    end
  end

  describe "#fetch_each" do
    it "returns a payload for each result found at the key" do
      hash = {:one => [{:two => 2}, {:two => 2}]}
      parser = Barometer::Payload.new(hash)

      expect { |b|
        parser.fetch_each(:one, &b)
      }.to yield_successive_args(Barometer::Payload, Barometer::Payload)
    end

    it "returns a payload for each result found at the key" do
      hash = {:one => [{:two => 2}, {:two => 2}]}
      parser = Barometer::Payload.new(hash)

      parser.fetch_each(:one) do |each_parser|
        each_parser.fetch(:two).should == 2
      end
    end

    it "raises an error when result is not an array" do
      hash = {:one => 1}
      parser = Barometer::Payload.new(hash)

      expect {
        parser.fetch_each(:one){ |p| nil }
      }.to raise_error(NoMethodError)
    end
  end

  describe "#fetch_each_with_index" do
    it "returns a payload for each result found at the key" do
      hash = {:one => [{:two => 2}, {:two => 2}]}
      parser = Barometer::Payload.new(hash)

      i = 0
      parser.fetch_each_with_index(:one) do |each_parser, index|
        each_parser.fetch(:two).should == 2
        index.should == i
        i += 1
      end
    end

    it "raises an error when result is not an array" do
      hash = {:one => 1}
      parser = Barometer::Payload.new(hash)

      expect {
        parser.fetch_each_with_index(:one){ |p| nil }
      }.to raise_error(NoMethodError)
    end
  end

  describe "#using" do
    it "applies the regex to the fetched result" do
      hash = {:one => 'two, three'}
      parser = Barometer::Payload.new(hash)
      parser.using(/^(.*),/).fetch(:one).should == 'two'
    end

    it "does nothing if valid regex does not exist" do
      hash = {:one => 'two, three'}
      parser = Barometer::Payload.new(hash)
      parser.using(:invalid_regex).fetch(:one).should == 'two, three'
    end

    it "does nothing if regex does not capture proper result" do
      hash = {:one => 'two, three'}
      parser = Barometer::Payload.new(hash)
      parser.using(/^.*,.*$/).fetch(:one).should == 'two, three'
    end

    it "forgets the regex" do
      hash = {:one => 'two, three'}
      parser = Barometer::Payload.new(hash)
      parser.using(/^(.*),/).fetch(:one).should == 'two'
      parser.fetch(:one).should == 'two, three'
    end
  end
end

