#
# extends HTTParty by adding configurable timeout support
#
module HTTParty
  class Request
    
    private
    
      def get_response
        self.last_response = perform_actual_request
        puts self.last_response.inspect
        puts self.last_response.body.inspect
        options[:format] ||= format_from_mimetype(last_response['content-type'])
      end
    
  end
end