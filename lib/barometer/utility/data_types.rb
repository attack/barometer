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

      def vector *names
        names.each do |name|
          send :define_method, name do
            value = instance_variable_get("@#{name}".to_sym)
            unless value
              value = Data::Vector.new
              instance_variable_set "@#{name}".to_sym, value
            end
            value
          end
        end

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            unless vector = instance_variable_get("@#{name}".to_sym)
              vector = Data::Vector.new
            end
            if respond_to?("metric")
              vector.metric = metric
            end
            vector << data
            instance_variable_set "@#{name}".to_sym, vector
          end
        end
      end

      def pressure *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            pressure = Data::Pressure.new
            if respond_to?("metric")
              pressure.metric = metric
            end
            pressure << data
            instance_variable_set "@#{name}".to_sym, pressure
          end
        end
      end

      def distance *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            distance = Data::Distance.new
            if respond_to?("metric")
              distance.metric = metric
            end
            distance << data
            instance_variable_set "@#{name}".to_sym, distance
          end
        end
      end

      def number *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            value = if data.respond_to?(:to_f)
              data.to_f
            else
              Float(data)
            end
            instance_variable_set "@#{name}".to_sym, value
          end
        end
      end

      def string *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless data
            instance_variable_set "@#{name}".to_sym, String(data)
          end
        end
      end

      def local_datetime *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = Array(data)
            return if data.compact.empty?

            if data.size <= 2
              local_datetime = Data::LocalDateTime.parse(*data)
            else
              local_datetime = Data::LocalDateTime.new(*data)
            end
            instance_variable_set "@#{name}".to_sym, local_datetime
          end
        end
      end

      def local_time *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = Array(data)
            return if data.compact.empty?

            if data.size <= 1
              local_time = Data::LocalTime.parse(*data)
            else
              local_time = Data::LocalTime.new(*data)
            end
            instance_variable_set "@#{name}".to_sym, local_time
          end
        end
      end

      def sun *names
        names.each do |name|
          send :define_method, name do
            value = instance_variable_get("@#{name}".to_sym)
            unless value
              value = Data::Sun.new
              instance_variable_set "@#{name}".to_sym, value
            end
            value
          end
        end
      end
    end
  end
end
