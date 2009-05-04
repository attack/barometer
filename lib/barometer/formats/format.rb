module Barometer
  #
  # Base Format Class
  #
  class Query::Format
  
    def self.is?(query=nil)
      raise ArgumentError unless query.is_a?(String)
      return !(query =~ self.regex).nil?
    end
      
    def self.regex; raise NotImplementedError; end
    def self.format; raise NotImplementedError; end
    def self.to(query=nil,format=nil, country=nil); nil; end
    def self.country_code(query=nil); nil; end
  
  end
end