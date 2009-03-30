module FactoryDataPreloader
  class Preloader
    attr_accessor :model_type, :model_class, :proc, :defined_index, :depends_on
  
    def initialize(model_type, model_class, proc, defined_index, depends_on)
      @model_type, @model_class, @proc, @defined_index, @depends_on = model_type, model_class, proc, defined_index, depends_on || []
    end
  
    def data
      @data ||= begin
        data = {}
        self.proc.try(:call, data)
        data
      end
    end
    
    def <=>(preloader)
      if self.depends_on.include?(preloader.model_type)
        1
      elsif preloader.depends_on.include?(self.model_type)
        -1
      else
        self.defined_index <=> preloader.defined_index
      end
    end
  end
end