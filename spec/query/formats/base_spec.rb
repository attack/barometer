require_relative '../../spec_helper'

describe Barometer::Query::Format::Base do
  describe "and class methods" do
    describe "is?," do
      it "calls a stubbed undefined method" do
        expect { Barometer::Query::Format::Base.is?("valid") }.to raise_error(NotImplementedError)
      end
    end

    it "stubs country_code" do
      Barometer::Query::Format::Base.country_code(nil).should be_nil
    end
  end
end
