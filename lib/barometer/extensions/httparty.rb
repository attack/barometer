#
# extends HTTParty by adding configurable timeout support
#
module HTTParty
  class Request
    
    private
    
      def get_response
        response = perform_actual_request
        puts response.inspect
        puts response.body.inspect
        options[:format] ||= format_from_mimetype(response['content-type'])
        response
      end
    
  end
end