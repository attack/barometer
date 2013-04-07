require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WebService do
  it "stubs fetch" do
    lambda { Barometer::WebService.fetch }.should raise_error(NotImplementedError)
  end
end
