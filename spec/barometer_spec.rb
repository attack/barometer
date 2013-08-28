require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Barometer do
  describe ".config" do
    around do |example|
      cached_config = Barometer.config
      example.run
      Barometer.config = cached_config
    end

    it "has a default value" do
      expect( Barometer.config ).to eq({ 1 => {:wunderground => {:version => :v1}} })
    end

    it "sets the value" do
      Barometer.config = { 1 => [:yahoo] }
      expect( Barometer.config ).to eq({ 1 => [:yahoo] })
    end
  end

  describe ".yahoo_placemaker_app_id" do
    around do |example|
      cache_key = Barometer.yahoo_placemaker_app_id
      example.run
      Barometer.yahoo_placemaker_app_id = cache_key
    end

    it "has a default value" do
      expect( Barometer.yahoo_placemaker_app_id ).to eq 'placemaker'
    end

    it "sets the Placemaker Yahoo! app ID" do
      Barometer.yahoo_placemaker_app_id = "YAHOO KEY"
      expect( Barometer.yahoo_placemaker_app_id ).to eq "YAHOO KEY"
    end
  end

  describe ".timeout" do
    it "has a default value" do
      expect( Barometer.timeout ).to eq 15
    end

    it "sets the value" do
      Barometer.timeout = 5
      expect( Barometer.timeout ).to eq 5
    end
  end
end
