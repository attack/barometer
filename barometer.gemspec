# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{barometer}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark G"]
  s.date = %q{2009-05-03}
  s.default_executable = %q{barometer}
  s.email = %q{barometer@attackcorp.com}
  s.executables = ["barometer"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/barometer", "lib/barometer", "lib/barometer/base.rb", "lib/barometer/data", "lib/barometer/data/current.rb", "lib/barometer/data/distance.rb", "lib/barometer/data/forecast.rb", "lib/barometer/data/geo.rb", "lib/barometer/data/location.rb", "lib/barometer/data/measurement.rb", "lib/barometer/data/pressure.rb", "lib/barometer/data/speed.rb", "lib/barometer/data/sun.rb", "lib/barometer/data/temperature.rb", "lib/barometer/data/units.rb", "lib/barometer/data/zone.rb", "lib/barometer/data.rb", "lib/barometer/extensions", "lib/barometer/extensions/graticule.rb", "lib/barometer/extensions/httparty.rb", "lib/barometer/query.rb", "lib/barometer/services", "lib/barometer/services/google.rb", "lib/barometer/services/noaa.rb", "lib/barometer/services/service.rb", "lib/barometer/services/weather_bug.rb", "lib/barometer/services/weather_dot_com.rb", "lib/barometer/services/wunderground.rb", "lib/barometer/services/yahoo.rb", "lib/barometer/services.rb", "lib/barometer/weather.rb", "lib/barometer.rb", "lib/demometer", "lib/demometer/demometer.rb", "lib/demometer/public", "lib/demometer/public/css", "lib/demometer/public/images", "lib/demometer/public/images/go.png", "lib/demometer/views", "lib/demometer/views/contributing.erb", "lib/demometer/views/forecast.erb", "lib/demometer/views/index.erb", "lib/demometer/views/layout.erb", "lib/demometer/views/measurement.erb", "lib/demometer/views/readme.erb", "spec/barometer_spec.rb", "spec/data_current_spec.rb", "spec/data_distance_spec.rb", "spec/data_forecast_spec.rb", "spec/data_geo_spec.rb", "spec/data_location_spec.rb", "spec/data_measurement_spec.rb", "spec/data_pressure_spec.rb", "spec/data_speed_spec.rb", "spec/data_sun_spec.rb", "spec/data_temperature_spec.rb", "spec/data_zone_spec.rb", "spec/fixtures", "spec/fixtures/current_calgary_ab.xml", "spec/fixtures/forecast_calgary_ab.xml", "spec/fixtures/geocode_40_73.xml", "spec/fixtures/geocode_90210.xml", "spec/fixtures/geocode_calgary_ab.xml", "spec/fixtures/geocode_ksfo.xml", "spec/fixtures/geocode_newyork_ny.xml", "spec/fixtures/geocode_T5B4M9.xml", "spec/fixtures/google_calgary_ab.xml", "spec/fixtures/yahoo_90210.xml", "spec/query_spec.rb", "spec/service_google_spec.rb", "spec/service_wunderground_spec.rb", "spec/service_yahoo_spec.rb", "spec/services_spec.rb", "spec/spec_helper.rb", "spec/units_spec.rb", "spec/weather_spec.rb", "LICENSE"]
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
