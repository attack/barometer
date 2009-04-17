module Barometer
  
  class Units
    
    attr_accessor :metric
    
    def initialize(metric=true)
      @metric = metric
    end
    
    #
    # HELPERS
    #
    
    def metric?
      @metric
    end
    
    def metric!
      @metric=true
    end
    
    def imperial!
      @metric=false
    end
    
  end
end