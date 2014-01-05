require_relative '../../spec_helper'

module Barometer::WeatherService
  describe WundergroundV1::CurrentResponse do
    it 'parses the timezones correctly' do
      payload = Barometer::Utils::Payload.new({
        'local_time' => 'May 18, 10:46 AM PDT'
      })
      response = WundergroundV1::CurrentResponse.new.parse(payload)

      current_year = Time.now.year
      utc_observed_at = Time.utc(current_year,5,18,17,46,0)
      utc_stale_at = Time.utc(current_year,5,18,18,0,0)

      expect( response.current.observed_at.utc ).to eq utc_observed_at
      expect( response.current.stale_at.utc ).to eq utc_stale_at
      expect( response.timezone.to_s ).to eq 'PDT'
    end
  end
end
