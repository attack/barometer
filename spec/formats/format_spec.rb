require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Query::Format" do

  describe "and class methods" do

    describe "is?," do

      it "requires a String" do
        invalid = 1
        lambda { Barometer::Query::Format.is?(invalid) }.should raise_error(ArgumentError)

        valid = "string"
        valid.is_a?(String).should be_true
        lambda { Barometer::Query::Format.is?(valid) }.should_not raise_error(ArgumentError)
      end

      it "calls a stubbed undefined method" do
        lambda { Barometer::Query::Format.is?("valid") }.should raise_error(NotImplementedError)
      end

    end

    describe "converts?," do

      it "requires a Query object" do
        invalid = 1
        Barometer::Query::Format.converts?(invalid).should be_false

        valid = Barometer::Query.new
        valid.is_a?(Barometer::Query).should be_true
        lambda { Barometer::Query::Format.converts?(valid) }.should_not raise_error(ArgumentError)
      end

      it "returns false" do
        valid = Barometer::Query.new
        Barometer::Query::Format.converts?(valid).should be_false
      end

    end

    it "detects a Query object" do
      invalid = 1
      Barometer::Query::Format.is_a_query?.should be_false
      Barometer::Query::Format.is_a_query?(invalid).should be_false
      valid = Barometer::Query.new
      valid.is_a?(Barometer::Query).should be_true
      Barometer::Query::Format.is_a_query?(valid).should be_true
    end

    it "stubs regex" do
      lambda { Barometer::Query::Format.regex }.should raise_error(NotImplementedError)
    end

    it "stubs format" do
      lambda { Barometer::Query::Format.format }.should raise_error(NotImplementedError)
    end

    it "stubs to" do
      Barometer::Query::Format.to.should be_nil
    end

    it "stubs country_code" do
      Barometer::Query::Format.country_code.should be_nil
    end

    it "stubs convertable_formats" do
      Barometer::Query::Format.convertable_formats.should == []
    end

    it "stubs convert_query" do
      Barometer::Query::Format.respond_to?(:convert_query).should be_true
    end

    it "normally does nothing when converting a query" do
      text = "this is a query"
      Barometer::Query::Format.convert_query(text).should == text
    end

  end

end
