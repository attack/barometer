require 'rubygems'
require 'sinatra'
require 'barometer'

# load API keys
@@config_file ||= File.expand_path(File.join('~', '.barometer'))
keys = YAML.load_file(@@config_file)
if keys["google"] && keys["google"]["geocode"]
  Barometer.google_geocode_key = keys["google"]["geocode"]
else
  raise RunTimeError "no geocoding keys"
  exit
end

class Demometer < Sinatra::Default

  def config_weather_dot_com
    if File.exists?(@@config_file)
    	keys = YAML.load_file(@@config_file)
    	if keys["weather"] && keys["weather"]["partner"] && keys["weather"]["license"]
    	  partner_key = keys["weather"]["partner"].to_s
    	  license_key = keys["weather"]["license"].to_s
      else
        raise RunTimeError "no weather.com keys"
        exit
      end
    else
      File.open(@@config_file, 'w') {|f| f << "\nweather:\n  partner: PARTNER_KEY\n  license: LICENSE_KEY" }
      raise RunTimeError "no weather.com keys"
      exit
    end
    { :weather_dot_com => { :keys => { :partner => partner_key, :license => license_key } } }
  end

  helpers do
    def data(title, value)
      return if value.nil?
      "<li>#{title}: #{value}</li>"
    end
  end

  get '/' do
    erb :index
  end
  
  post '/' do
    # apply options
    Barometer.force_geocode = (params[:query][:geocode].to_s == "1" ? true : false)
    metric = (params[:query][:metric].to_s == "1" ? true : false)
    
    # determine sources
    Barometer.config = { 1 => params[:query][:source].collect{|s| s.to_sym } }
    
    # setup weather.com
    if Barometer::Base.config && Barometer::Base.config[1] &&
      Barometer::Base.config[1].include?(:weather_dot_com)
      Barometer::Base.config[1].delete(:weather_dot_com)
      Barometer::Base.config[1] << config_weather_dot_com
    end
    
    if params[:query] && !params[:query][:q].empty?
      @barometer = Barometer.new(params[:query][:q])
      @weather = @barometer.measure(metric)
    end
    erb :index
  end

  get '/contributing.html' do
    erb :contributing
  end
  
  get '/readme.html' do
    erb :readme
  end

end