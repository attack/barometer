require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Barometer do
  describe ".config" do
    it "has a default value" do
      Barometer.config.should == { 1 => [:wunderground] }
    end

    it "sets the value" do
      cached_config = Barometer.config

      Barometer.config = { 1 => [:yahoo] }
      Barometer.config.should == { 1 => [:yahoo] }

      Barometer.config = cached_config
    end
  end

  describe ".yahoo_placemaker_app_id" do
    it "has a default value" do
      Barometer.yahoo_placemaker_app_id = nil
    end

    it "sets the Placemaker Yahoo! app ID" do
      cache_key = Barometer.yahoo_placemaker_app_id

      Barometer.yahoo_placemaker_app_id.should be_nil
      Barometer.yahoo_placemaker_app_id = "YAHOO KEY"
      Barometer.yahoo_placemaker_app_id.should == "YAHOO KEY"

      Barometer.yahoo_placemaker_app_id = cache_key
    end
  end

  describe ".timeout" do
    it "has a default value" do
      Barometer.timeout.should == 15
    end

    it "sets the value" do
      Barometer.timeout = 5
      Barometer.timeout.should == 5
    end
  end
end
