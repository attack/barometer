require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Web Services" do
  describe "and the class method" do
    describe "source" do
      it "stubs fetch" do
        lambda { Barometer::WebService.fetch }.should raise_error(NotImplementedError)
      end

      it "detects a Query object" do
        invalid = 1
        Barometer::WebService.send("_is_a_query?").should be_false
        Barometer::WebService.send("_is_a_query?", invalid).should be_false
        valid = Barometer::Query.new
        valid.is_a?(Barometer::Query).should be_true
        Barometer::WebService.send("_is_a_query?", valid).should be_true
      end
    end
  end
end
