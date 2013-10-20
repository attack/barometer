require_relative '../../spec_helper'

module Barometer::WeatherService
  describe WeatherBug::CurrentResponse do
    it "parses the timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        'ob_date' => {
          'year' => { '@number' => '2013' },
          'month' => { '@number' => '5' },
          'day' => { '@number' => '18' },
          'hour' => { '@hour_24' => '10' },
          'minute' => { '@number' => '46' },
          'second' => { '@number' => '0' },
          'time_zone' => { '@abbrv' => 'PDT' }
        }
      })
      response = WeatherBug::CurrentResponse.new.parse(payload)

      utc_observed_at = Time.utc(2013,5,18,17,46,0)
      utc_stale_at = Time.utc(2013,5,18,18,46,0)

      expect( response.current.observed_at.utc ).to eq utc_observed_at
      expect( response.current.stale_at.utc ).to eq utc_stale_at
      expect( response.timezone.to_s ).to eq 'PDT'
    end

    it "parses sun timezones correctly" do
      payload = Barometer::Utils::Payload.new({
        'ob_date' => {
          'year' => { '@number' => '2013' },
          'month' => { '@number' => '4' },
          'day' => { '@number' => '13' },
          'hour' => { '@hour_24' => '10' },
          'minute' => { '@number' => '23' },
          'second' => { '@number' => '0' },
          'time_zone' => { '@abbrv' => 'PDT' }
        },
        'sunrise' => {
          'year' => { '@number' => '2013' },
          'month' => { '@number' => '4' },
          'day' => { '@number' => '13' },
          'hour' => { '@hour_24' => '6' },
          'minute' => { '@number' => '44' },
          'second' => { '@number' => '19' },
        },
        'sunset' => {
          'year' => { '@number' => '2013' },
          'month' => { '@number' => '4' },
          'day' => { '@number' => '13' },
          'hour' => { '@hour_24' => '17' },
          'minute' => { '@number' => '31' },
          'second' => { '@number' => '50' },
        }
      })
      response = WeatherBug::CurrentResponse.new.parse(payload)

      utc_current_sun_rise = Time.utc(2013,4,13,13,44,19)
      utc_current_sun_set = Time.utc(2013,4,14,0,31,50)

      expect( response.current.sun.rise.utc ).to eq utc_current_sun_rise
      expect( response.current.sun.set.utc ).to eq utc_current_sun_set
    end
  end
end
