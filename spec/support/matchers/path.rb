module BarometerMatchers
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
      path_value.to_s
    end
  end
end
