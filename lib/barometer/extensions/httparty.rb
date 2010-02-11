#
# extends HTTParty by adding configurable timeout support
#
module HTTParty
  class Request
        
    private
    
      def http
        http = Net::HTTP.new(uri.host, uri.port, options[:http_proxyaddr], options[:http_proxyport])
        http.use_ssl = (uri.port == 443)
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if options[:timeout] && options[:timeout].is_a?(Integer)
          http.open_timeout = options[:timeout]
          http.read_timeout = options[:timeout]
        end
        http
      end
    
  end
end