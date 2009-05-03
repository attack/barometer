require 'rubygems'
require 'sinatra'
require 'barometer'

# load API keys
keys = YAML.load_file(File.expand_path(File.join('~', '.barometer')))
if keys["geocode_google"]
  Barometer.google_geocode_key = keys["geocode_google"]
else
  exit
end

class Demometer < Sinatra::Default

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