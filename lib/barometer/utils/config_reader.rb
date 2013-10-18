module Barometer
  module Utils
    module ConfigReader
      def self.take_level_while(&block)
        Barometer.config.take_while do |level, level_config|
          yield level
        end
      end

      def self.services(level, &block)
        _dig(Barometer.config[level], {}, &block)
      end

      # iterate through the setup until we have a source name (and possibly
      # a config for that source), then yield with that source and config
      #
      # this allows for many different config formats, like
      # { 1 => :wunderground }
      # { 1 => [:wunderground]}
      # { 1 => [:wunderground, :yahoo]}
      # { 1 => [:wunderground, {yahoo: {weight: 2}}]}
      # { 1 => {wunderground: {weight: 2}}}
      # { 1 => [{wunderground: {weight: 2}}]}
      #
      def self._dig(data, config, &block)
        if data.respond_to?(:to_sym)
          yield(data.to_sym, config)
        elsif data.is_a?(Array)
          data.each do |datum|
            _dig(datum, {}, &block)
          end
        elsif data.is_a?(Hash)
          data.each do |datum, config|
            _dig(datum, config, &block)
          end
        end
      end
    end
  end
end
