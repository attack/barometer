module Barometer
  #
  # Base Format Class
  #
  class Query::Format
  
    # Stubs
    #
    def self.regex; raise NotImplementedError; end
    def self.format; raise NotImplementedError; end
    
    # Defaults
    #
    def self.to(query=nil,country=nil); nil; end
    def self.country_code(query=nil); nil; end
    def self.convertable_formats; []; end
    
    def self.is?(query=nil)
      raise ArgumentError unless query.is_a?(String)
      return !(query =~ self.regex).nil?
    end

    # does the format support conversion from the given query?
    def self.converts?(query=nil)
      return false unless is_a_query?(query)
      self.convertable_formats.include?(query.format)
    end

    def self.is_a_query?(object=nil)
      return false unless object
      object.is_a?(Barometer::Query)
    end
  
  end
end