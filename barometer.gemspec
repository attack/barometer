# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{barometer}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark G"]
  s.date = %q{2009-05-15}
  s.default_executable = %q{barometer}
  s.email = %q{barometer@attackcorp.com}
  s.executables = ["barometer"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/barometer", "lib/barometer", "lib/barometer/base.rb", "lib/barometer/data", "lib/barometer/data/distance.rb", "lib/barometer/data/geo.rb", "lib/barometer/data/local_datetime.rb", "lib/barometer/data/local_time.rb", "lib/barometer/data/location.rb", "lib/barometer/data/pressure.rb", "lib/barometer/data/speed.rb", "lib/barometer/data/sun.rb", "lib/barometer/data/temperature.rb", "lib/barometer/data/units.rb", "lib/barometer/data/zone.rb", "lib/barometer/data.rb", "lib/barometer/extensions", "lib/barometer/extensions/httparty.rb", "lib/barometer/formats", "lib/barometer/formats/coordinates.rb", "lib/barometer/formats/format.rb", "lib/barometer/formats/geocode.rb", "lib/barometer/formats/icao.rb", "lib/barometer/formats/postalcode.rb", "lib/barometer/formats/short_zipcode.rb", "lib/barometer/formats/weather_id.rb", "lib/barometer/formats/zipcode.rb", "lib/barometer/formats.rb", "lib/barometer/measurements", "lib/barometer/measurements/common.rb", "lib/barometer/measurements/current.rb", "lib/barometer/measurements/forecast.rb", "lib/barometer/measurements/forecast_array.rb", "lib/barometer/measurements/measurement.rb", "lib/barometer/measurements/night.rb", "lib/barometer/query.rb", "lib/barometer/services.rb", "lib/barometer/translations", "lib/barometer/translations/icao_country_codes.yml", "lib/barometer/translations/weather_country_codes.yml", "lib/barometer/translations/zone_codes.yml", "lib/barometer/weather.rb", "lib/barometer/weather_services", "lib/barometer/weather_services/google.rb", "lib/barometer/weather_services/noaa.rb", "lib/barometer/weather_services/service.rb", "lib/barometer/weather_services/weather_bug.rb", "lib/barometer/weather_services/weather_dot_com.rb", "lib/barometer/weather_services/wunderground.rb", "lib/barometer/weather_services/yahoo.rb", "lib/barometer/web_services", "lib/barometer/web_services/geocode.rb", "lib/barometer/web_services/timezone.rb", "lib/barometer/web_services/weather_id.rb", "lib/barometer/web_services/web_service.rb", "lib/barometer.rb", "lib/demometer", "lib/demometer/demometer.rb", "lib/demometer/public", "lib/demometer/public/css", "lib/demometer/public/css/master.css", "lib/demometer/public/css/print.css", "lib/demometer/public/css/syntax.css", "lib/demometer/public/images", "lib/demometer/public/images/go.png", "lib/demometer/public/images/link-out.gif", "lib/demometer/views", "lib/demometer/views/about.erb", "lib/demometer/views/contributing.erb", "lib/demometer/views/forecast.erb", "lib/demometer/views/index.erb", "lib/demometer/views/layout.erb", "lib/demometer/views/measurement.erb", "lib/demometer/views/readme.erb", "spec/barometer_spec.rb", "spec/data", "spec/data/distance_spec.rb", "spec/data/geo_spec.rb", "spec/data/local_datetime_spec.rb", "spec/data/local_time_spec.rb", "spec/data/location_spec.rb", "spec/data/pressure_spec.rb", "spec/data/speed_spec.rb", "spec/data/sun_spec.rb", "spec/data/temperature_spec.rb", "spec/data/units_spec.rb", "spec/data/zone_spec.rb", "spec/fixtures", "spec/fixtures/formats", "spec/fixtures/formats/weather_id", "spec/fixtures/formats/weather_id/90210.xml", "spec/fixtures/formats/weather_id/atlanta.xml", "spec/fixtures/formats/weather_id/from_USGA0028.xml", "spec/fixtures/formats/weather_id/ksfo.xml", "spec/fixtures/formats/weather_id/new_york.xml", "spec/fixtures/geocode", "spec/fixtures/geocode/40_73.xml", "spec/fixtures/geocode/90210.xml", "spec/fixtures/geocode/atlanta.xml", "spec/fixtures/geocode/calgary_ab.xml", "spec/fixtures/geocode/ksfo.xml", "spec/fixtures/geocode/newyork_ny.xml", "spec/fixtures/geocode/T5B4M9.xml", "spec/fixtures/services", "spec/fixtures/services/google", "spec/fixtures/services/google/calgary_ab.xml", "spec/fixtures/services/weather_bug", "spec/fixtures/services/weather_bug/90210_current.xml", "spec/fixtures/services/weather_bug/90210_forecast.xml", "spec/fixtures/services/weather_dot_com", "spec/fixtures/services/weather_dot_com/90210.xml", "spec/fixtures/services/wunderground", "spec/fixtures/services/wunderground/current_calgary_ab.xml", "spec/fixtures/services/wunderground/forecast_calgary_ab.xml", "spec/fixtures/services/yahoo", "spec/fixtures/services/yahoo/90210.xml", "spec/formats", "spec/formats/coordinates_spec.rb", "spec/formats/format_spec.rb", "spec/formats/geocode_spec.rb", "spec/formats/icao_spec.rb", "spec/formats/postalcode_spec.rb", "spec/formats/short_zipcode_spec.rb", "spec/formats/weather_id_spec.rb", "spec/formats/zipcode_spec.rb", "spec/measurements", "spec/measurements/common_spec.rb", "spec/measurements/current_spec.rb", "spec/measurements/forecast_array_spec.rb", "spec/measurements/forecast_spec.rb", "spec/measurements/measurement_spec.rb", "spec/measurements/night_measurement_spec.rb", "spec/query_spec.rb", "spec/spec_helper.rb", "spec/weather_services", "spec/weather_services/google_spec.rb", "spec/weather_services/services_spec.rb", "spec/weather_services/weather_bug_spec.rb", "spec/weather_services/weather_dot_com_spec.rb", "spec/weather_services/wunderground_spec.rb", "spec/weather_services/yahoo_spec.rb", "spec/weather_spec.rb", "spec/web_services", "spec/web_services/geocode_spec.rb", "spec/web_services/web_services_spec.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/attack/barometer}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{barometer}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
