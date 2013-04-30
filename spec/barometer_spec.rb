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

describe Barometer::Base do
  let(:query_term) { "Calgary, AB" }
  subject { Barometer::Base.new(query_term) }

  describe "#new" do
    it "sets the query" do
      subject.query.should be_a(Barometer::Query::Base)
      subject.query.q.should == query_term
    end

    it "initializes a Weather object" do
      subject.weather.should be_a(Barometer::Weather)
    end
  end

  describe "#measure" do
    let(:keys) { {:code => "ABC123"} }
    let(:response) { Barometer::Response.new }
    let(:weather_service) { double(:weather_service, :call => response) }

    before do
      @services_cache = Barometer::WeatherService.services
      Barometer::WeatherService.services = Barometer::Utils::VersionedRegistration.new

      @cached_config = Barometer.config
      Barometer.config = { 1 => {:test => {:keys => keys} } }
      Barometer::WeatherService.register(:test, weather_service)

      response.stub(:complete? => true)
    end

    after do
      Barometer::WeatherService.services = @services_cache
      Barometer.config = @cached_config
    end

    it "returns a Weather object" do
      subject.measure.should be_a(Barometer::Weather)
    end

    it "calls measure on WeatherService, including metric and keys" do
      metric = double(:boolean)
      response.stub(:success? => true)

      Barometer::WeatherService.should_receive(:measure).
        with(:test, subject.query, {:metric => metric, :keys => keys}).
        and_return(response)

      subject.measure(metric)
    end

    it "adds service results to weather.responses" do
      subject.measure
      subject.weather.responses.should include(response)
    end

    it "raises an error if no sources are successful" do
      response.stub(:success? => false)

      expect {
        subject.measure
      }.to raise_error(Barometer::OutOfSources)
    end

    it "sets the weight" do
      Barometer.config = { 1 => {:test => {:weight => 2} } }
      subject.measure
      subject.weather.responses.first.weight.should == 2
    end
  end
end
