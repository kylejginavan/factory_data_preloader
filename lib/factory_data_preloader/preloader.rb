module FactoryDataPreloader
  class Preloader
    attr_accessor :model_type, :model_class, :proc, :defined_index
  
    def initialize(model_type, model_class, proc, defined_index)
      @model_type, @model_class, @proc, @defined_index = model_type, model_class, proc, defined_index
    end
  
    def data
      @data ||= begin
        data = {}
        self.proc.try(:call, data)
        data
      end
    end
  end
end