require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Parser::NoaaForecast do
  let(:measurement) { Barometer::Measurement.new }
  let(:query) { double(:query, :add_conversion => nil) }

  it "parses the timezones correctly" do
    payload = Barometer::Payload.new({
      "time_layout" => [
        {
          "layout_key"=> "k-p12h-n14-2",
          "start_valid_time" => ["2013-02-09T06:00:00-08:00"],
          "end_valid_time" => ["2013-02-09T18:00:00-08:00"]
        }
      ],
      "parameters" => {
        "temperature" => [
          {"value"=>["55"], "@type"=>"maximum"},
          {"@type"=>"minimum"}
        ],
        "probability_of_precipitation" => { "value" => [] },
        "weather" => { "weather_conditions" => [] },
        "conditions_icon" => { "icon_link" => [] }
      }
    })
    parser = Barometer::Parser::NoaaForecast.new(measurement, query)
    parser.parse(payload)

    utc_starts_at = Time.utc(2013,2,9,14,0,0)
    utc_ends_at = Time.utc(2013,2,10,2,0,0)

    measurement.forecast[0].starts_at.utc.should == utc_starts_at
    measurement.forecast[0].ends_at.utc.should == utc_ends_at
  end
end
