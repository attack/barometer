module Barometer
  module Matchers
    class Walker
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def follow(paths)
        path_value = value
        paths.each do |path|
          path_value = path_value.send(path)
        end
        if path_value.respond_to?(:strftime)
          path_value.strftime("%Y-%m-%d %H:%M:%S %z")
        else
          path_value.to_s
        end
      end
    end
  end
end
