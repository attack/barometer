# barometer

[![Build Status](https://travis-ci.org/attack/barometer.png?branch=master)](https://travis-ci.org/attack/barometer)
[![Gem Version](https://badge.fury.io/rb/barometer.png)](http://badge.fury.io/rb/barometer)

A multi API consuming weather forecasting superstar.

Barometer provides a common public API to one or more weather services (APIs)
of your choice.  Weather services can co-exist to retrieve extensive
information, or they can be used in a hierarchical configuration where lower
preferred weather services are only used if previous services are
unavailable.

Barometer handles all conversions of the supplied query, so that the
same query can be used for all (or most) services, even if they don't
support the query directly. See the "Query" section for more information on
this.

## key features

* works with ruby 1.8.7, 1.9.x, 2.0, Rubinius, REE (see
  [Travis CI status](https://travis-ci.org/attack/barometer) to confirm)
* supports 4 weather services, more planned
* the same query can be used with any supported weather service
* provides a powerful data object to hold the weather information
* provides a simple plugin api to allow more weather services to be added
* failover configuration
* multiple services configuration to provide average values

# usage

You can use barometer right out of the box, as it is configured to use one
register-less (no API key required) international weather service
(wunderground.com).

```ruby
require 'barometer'

barometer = Barometer.new("Paris")
weather = barometer.measure

puts weather.current.temperature
```

*See [detailed usage](#detailed_Usage) further down.*

# dependencies

[![Dependency Status](https://gemnasium.com/attack/barometer.png)](https://gemnasium.com/attack/barometer)

## api keys

The '~/.barometer' file can hold all your weather service API keys.

eg. weatherbug.com

  weather_bug:
    code: YOUR_API_CODE

eg. Yahoo! Placemaker

  yahoo:
    app_id: YOUR_APP_ID

## httpclient

[httpclient](https://github.com/nahi/httpclient) is a fast, pure ruby, feature complete 
library for making http requests.

## tzinfo

Why? Barometer deals with time information for locations all over the world.
This information doesn't mean that much if it can't be converted to times 
that don't correspond to the applicable timezone.
Tzinfo handles this time zone manipulation.

# queries

The query handling is one of the most beneficial and powerful features of
Barometer.  Every weather service accepts a different set of possible
queries, so it usually is the case that the same query can only be used
for a couple weather services.

Barometer will allow the use of all query formats for all services
(mostly).  It does this by first determining the original query format,
then converting the query to a compatible format for each specific
weather service.

For example, Yahoo! only accepts US Zip Code or Weather.com ID.  With Barometer
you can query Yahoo! with a simple location (ie: Paris) or even an Airport
code (ICAO) and it will return the weather as expected.

## acceptable formats

* zipcode
* icao (international airport code)
* coordinates (latitude and longitude)
* postal code
* weather.com ID
* location name (ie address, city, state, landmark, etc.)
* woeid (where on earth id, by Yahoo!)

*if the query is of the formats zipcode or postal code it may not
support conversion to other formats.*

## conversion caching

Barometer has internal conversion caching.  No conversion will be
repeated during a measurement, thus limiting the number of web queries
needed.

Example: If you configure Barometer to use both Yahoo and Weather.com,
then use a query like "denver", this will require a conversion from
"denver" to its weather.com weather_id.  This conversion is needed for
both web services but will only happen once and be cached.

<a name='detailed_Usage'></a>
# detailed usage

## sources

The available sources are:

* Wunderground.com (:wunderground) [default]
* Yahoo! Weather (:yahoo)
* WeatherBug.com (:weather_bug) [requires key]
* NOAA (:noaa)

## source configuration

Barometer can be configured to use multiple weather service APIs (either in
a primary/failover config or in parallel).  Each weather service can also
have its own config.

Weather services in parallel

```ruby
Barometer.config = { 1 => [:yahoo, :wunderground] }
```

Weather services in primary/failover

```ruby
Barometer.config = { 1 => [:yahoo], 2 => :wunderground }
```

Weather services, one with some configuration. In this case we are setting
a weight value, this weight is respected when calculating averages.

```ruby
Barometer.config = { 1 => [{:wunderground => {:weight => 2}}, :yahoo] }
```

Weather services, one with keys.

```ruby
Barometer.config = { 1 => [:yahoo, {:weather_bug => {:keys => {:code => CODE_KEY} }}] }
```

### multiple weather API, with hierarchy

```ruby
require 'barometer'

# use yahoo and weather bug, if they both fail, use wunderground
Barometer.config = { 1 => [:yahoo, {:weather_bug => {:keys => {:code => CODE_KEY} }}], 2 => :wunderground }

barometer = Barometer.new("Paris")
weather = barometer.measure

puts weather.current.temperture
```

## command line

You can use barometer from the command line. 

  # barometer berlin

This will output the weather information for the given query.
See the help for more command line information.

  # barometer -h

## searching

After you have measured the data, Barometer provides several methods to help
you get the data you are after. All examples assume you already have measured
the data as shown in the above examples.

### by preference (default service)

```ruby
weather.default         # returns measurement for default source
weather.current         # returns current_measurement for default
weather.now             # returns current_measurement for default
weather.forecast        # returns all forecast_measurements for default
weather.today           # returns forecast_measurement for default today
weather.tomorrow        # returns forecast_measurement for default tomorrow

puts weather.now.temperature.c
puts weather.tomorrow.high.c
```

### by date

```ruby
# note, the date is the date of the locations weather, not the date of the
# user measuring the weather
date = Date.parse("01-01-2009")
weather.for(date)       # returns forecast_measurement for default on date 

puts weather.for(date).high.c
```

### by time

```ruby
# note, the time is the time of the locations weather, not the time of the
# user measuring the weather
time = Time.parse("13:00 01-01-2009")
weather.for(time)       # returns forecast_measurement for default at time 

puts weather.for(time).low.f
```

## averages

If you consume more then one weather service, Barometer can provide averages
for the values (currently only for the 'current' values and not the forecasted
values).

```ruby
require 'barometer'

# use yahoo and wunderground
Barometer.config = { 1 => [:yahoo, :wunderground] }

barometer = Barometer.new("90210")
weather = barometer.measure

puts weather.temperture
```

This will calculate the average temperature as given by :yahoo and :wunderground

### weights

You can weight the values from a weather service so that the values from that
web service have more influence then other values.  The weights are set in the
config ... see the config section
  
# design

[![Code Climate](https://codeclimate.com/github/attack/barometer.png)](https://codeclimate.com/github/attack/barometer)

* create a Barometer instance
* supply a query, there are very little restrictions on the format:
  * city, country, specific address (basically anything Google will geocode)
  * US zip code
  * postal code
  * latitude and longitude
  * weather.com weather id (even if the service you are using doesn't use it)
  * international airport code
* determine which weather services will be queried (one or multiple)    
* if query conversion required for specific weather service, convert the query
* query the weather services
* save the data
* repeat weather service queries as needed

# extending

Barometer attempts to be a common API to any weather service API.  I have included
several weather service 'drivers', but I know there are many more available.
Please use the provided ones as examples to create more.

# development

Barometer uses 'bundler'.  You just need to 'git clone' the repo and 'bundle install'.

## Contributions

Thank you to these developers who have contributed. No contribution is too small.

* nofxx (https://github.com/nofxx)
* floere (https://github.com/floere)
* plukevdh (https://github.com/plukevdh)
* gkop (https://github.com/gkop)

# Links

* repo: http://github.com/attack/barometer
* rdoc: http://rdoc.info/projects/attack/barometer
* travis ci: https://travis-ci.org/attack/barometer
* code climate: https://codeclimate.com/github/attack/barometer

## copyright

Copyright (c) 2009-2013 Mark G. See LICENSE for details.
