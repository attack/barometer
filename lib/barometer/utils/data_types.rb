module Barometer
  module Utils
    module DataTypes
      def self.included base
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def metric=(value); @metric = !!value; end
        def metric; @metric; end
        def metric?;  @metric || @metric.nil?;  end
      end
    end
  end
end
