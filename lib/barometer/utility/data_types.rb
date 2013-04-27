module Barometer
  module DataTypes
    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def metric=(value); @metric = !!value; end
      def metric; @metric; end
      def metric?;  @metric || @metric.nil?;  end
    end

    module ClassMethods
      def pre_set_reader type, *names
        names.each do |name|
          send :define_method, name do
            value = instance_variable_get("@#{name}")
            unless value
              value = type.new
              instance_variable_set "@#{name}", value
            end
            value
          end
        end
      end

      def new_pre_set_reader type, *names
        names.each do |name|
          send :define_method, name do
            value = instance_variable_get("@#{name}")
            if value.respond_to?(:metric=)
              value.metric = metric?
            end
            value
          end
        end
      end

      def new_pre_set_writer type, *names
        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return unless instance_variable_get("@#{name}").nil?
            if data.is_a?(type)
              instance = data
            else
              instance = type.new(*data)
            end
            instance.metric = metric?
            instance_variable_set "@#{name}", instance
          end
        end
      end

      def temperature *names
        new_pre_set_reader Data::Temperature, *names
        new_pre_set_writer Data::Temperature, *names
      end

      def vector *names
        new_pre_set_reader Barometer::Data::Vector, *names
        new_pre_set_writer Barometer::Data::Vector, *names
      end

      def pressure *names
        new_pre_set_reader Data::Pressure, *names
        new_pre_set_writer Data::Pressure, *names
      end

      def distance *names
        new_pre_set_reader Data::Distance, *names
        new_pre_set_writer Data::Distance, *names
      end

      def float *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            elsif data.respond_to?(:to_f)
              value = data.to_f
            else
              value = Float(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def integer *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            elsif data.respond_to?(:to_i)
              value = data.to_i
            else
              value = Integer(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def string *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            else
              value = String(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def symbol *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data.respond_to?(:to_sym)
              instance_variable_set "@#{name}", data.to_sym
            elsif data == nil
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def time *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = [data] unless data.is_a?(Array)
            return unless data && data.first

            time = Barometer::Helpers::Time.parse(*data)
            instance_variable_set "@#{name}", time
          end
        end
      end

      def sun *names
        pre_set_reader Data::Sun, *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            return if data.nil?
            if data.is_a?(Data::Sun)
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def location *names
        pre_set_reader Data::Location, *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              instance_variable_set "@#{name}", nil
            elsif data.is_a?(Data::Location)
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def timezone *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              timezone = nil
            elsif data.is_a?(Data::Zone)
              timezone = data
            elsif data
              timezone = Data::Zone.new(data)
            end
            instance_variable_set "@#{name}", timezone
          end
        end
      end

      def boolean *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = !!data if data != nil
            instance_variable_set "@#{name}", data
          end

          send :define_method, "#{name}?" do
            !!instance_variable_get("@#{name}")
          end
        end
      end

    end
  end
end
