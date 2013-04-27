require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Utils::KeyFileParser do
  include FakeFS::SpecHelpers

  it "returns the the KEY for the given path" do
    FakeFS do
      FileUtils.mkdir("~")
      File.open(Barometer::KEY_FILE, 'w') {|f| f << "\weather_bug:\n  code: ABC123" }
      Barometer::Utils::KeyFileParser.find(:weather_bug, :code).should == "ABC123"
    end
  end

  it "returns nil when the key does not exist" do
    FakeFS do
      FileUtils.mkdir("~")
      File.open(Barometer::KEY_FILE, 'w') {|f| f << "\weather_bug:\n" }
      Barometer::Utils::KeyFileParser.find(:weather_bug, :code).should be_nil
    end
  end

  it "returns nil when the file does not exist" do
    FakeFS do
      FileUtils.mkdir("~")
      Barometer::Utils::KeyFileParser.find(:weather_bug, :code).should be_nil
    end
  end
end
