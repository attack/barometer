require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Format::Base do
  describe "and class methods" do
    describe "is?," do
      it "requires a String" do
        invalid = 1
        lambda { Barometer::Query::Format::Base.is?(invalid) }.should raise_error(ArgumentError)

        valid = "string"
        valid.is_a?(String).should be_true
        lambda { Barometer::Query::Format::Base.is?(valid) }.should_not raise_error(ArgumentError)
      end

      it "calls a stubbed undefined method" do
        lambda { Barometer::Query::Format::Base.is?("valid") }.should raise_error(NotImplementedError)
      end
    end

    it "stubs country_code" do
      Barometer::Query::Format::Base.country_code(nil).should be_nil
    end
  end
end
