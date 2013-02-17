module Barometer
  module DataTypes
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods

      def temperature *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            temperature = Data::Temperature.new
            if respond_to?("metric")
              temperature.metric = metric
            end
            temperature << data
            instance_variable_set "@#{name}".to_sym, temperature
          end
        end
      end

    end
  end
end
