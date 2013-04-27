module Barometer
  class Payload
    attr_reader :hash, :regex

    def initialize(hash)
      @hash = hash
    end

    def using(regex)
      @regex = regex
      self
    end

    def fetch(*paths)
      if hash
        result = paths.inject(hash) { |result, path| result.fetch(path, nil) || break }
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
          result_payload = Barometer::Payload.new(result)
          block.call(result_payload)
        end
      end
    end

    def each_with_index(*paths, &block)
      fetch(*paths).each_with_index do |result, index|
        result_payload = Barometer::Payload.new(result)
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
