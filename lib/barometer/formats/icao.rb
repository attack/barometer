module Barometer
  #
  # Format: ICAO (International Civil Aviation Organization)
  #
  # eg. KLAX (Los Angeles Airport) 
  #
  # This class is used to determine if a query is a
  # :icao and what the country_code is.
  #
  class Query::Icao < Query::Format
  
    CODES_FILE = File.expand_path(
      File.join('lib', 'barometer', 'translations', 'icao_country_codes.yml'))
    @@codes = nil

    def self.format; :icao; end
    
    # call any 3-4 letter query, :icao ... obviously this will have a lot
    # of false positives.  So far this isn't an issue as all weather services
    # that take :icao (which is just one, :wunderground) also take what
    # this would have been if it was not called :icao.
    #
    def self.regex; /^[A-Za-z]{3,4}$/; end
    
    # # in some cases the first letter can designate the country
    # #
    def self.country_code(query=nil)
      return unless query && query.is_a?(String)
      @@codes ||= YAML.load_file(CODES_FILE)
      return unless @@codes && @@codes['one_letter'] && @@codes['two_letter']
      @@codes['one_letter'][query[0..0].upcase.to_s] ||
        @@codes['two_letter'][query[0..1].upcase.to_s] || nil
    end
  
  end
end