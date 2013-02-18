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
      result.respond_to?(:strip) ? result.strip : result
    end

    private

    def _apply_regex(result)
      if @regex && @regex.is_a?(Regexp) && matched = result.to_s.match(@regex)
        result = matched[1] if matched[1]
      end
      result
    end
  end
end
