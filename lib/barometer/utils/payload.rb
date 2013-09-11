module Barometer
  module Utils
    class Payload
      attr_reader :hash, :regex, :query

      def initialize(hash, query=nil)
        @hash = hash
        @query = query
      end

      def using(regex)
        @regex = regex
        self
      end

      def fetch(*paths)
        if hash
          result = fetch_value_or_attribute(paths)
        else
          result = nil
        end

        result = _apply_regex(result)
        result = _cleanup(result)
        result = _convert_alternate_nil_values(result)

        result
      end

      def each(*paths, &block)
        path = fetch(*paths)
        if path
          path.each do |result|
            result_payload = Barometer::Utils::Payload.new(result)
            block.call(result_payload)
          end
        end
      end

      def each_with_index(*paths, &block)
        fetch(*paths).each_with_index do |result, index|
          result_payload = Barometer::Utils::Payload.new(result)
          block.call(result_payload, index)
        end
      end

      def fetch_each(*paths, &block)
        each(*paths, &block)
      end

      def fetch_each_with_index(*paths, &block)
        each_with_index(*paths, &block)
      end

      private

      def fetch_value_or_attribute(paths)
        result = paths.inject(hash) do |result, path|
          fetch_value(result, path) || fetch_attribute(result, path) || break
        end
      end

      def fetch_value(result, path)
        if result.respond_to? :fetch
          result.fetch(path, nil)
        end
      end

      def fetch_attribute(result, path)
        if path.to_s.start_with?('@') && result.respond_to?(:attributes)
          result.attributes.fetch(path.slice(1..-1))
        end
      end

      def _apply_regex(result)
        if @regex && @regex.is_a?(Regexp) && matched = result.to_s.match(@regex)
          result = matched[1] if matched[1]
        end
        @regex = nil
        result
      end

      def _cleanup(result)
        result.respond_to?(:strip) ? result.strip : result
      end

      def _convert_alternate_nil_values(result)
        if result == "NA"
          nil
        else
          result
        end
      end
    end
  end
end
