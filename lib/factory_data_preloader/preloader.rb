module FactoryDataPreloader
  class PreloaderNotDefinedError < StandardError; end

  mattr_accessor :preload_all
  self.preload_all = true

  mattr_accessor :preload_types
  self.preload_types = []

  class << self
    alias :preload_all? :preload_all

    def requested_preloaders
      @requested_preloaders ||= begin
        if preload_all?
          AllPreloaders.instance
        else
          preloaders = self.preload_types.collect { |type| AllPreloaders.instance.from_symbol(type) }
          preloaders += (preloaders.collect { |p| p.all_dependencies }).flatten
          preloaders.uniq!
          PreloaderCollection.new(preloaders)
        end
      end
    end
  end

  class Preloader
    attr_accessor :model_type, :model_class, :proc, :depends_on

    def initialize(model_type, model_class, proc, depends_on)
      @model_type, @model_class, @proc, @depends_on = model_type, model_class, proc, depends_on || []
      AllPreloaders.instance << self
    end

    def data
      @data ||= begin
        data = PreloaderDataHash.new
        print "Preloading #{model_type}:"
        benchmark_measurement = Benchmark.measure { self.proc.try(:call, data) }
        print "(#{format('%.3f', benchmark_measurement.real)} secs)\n"
        data
      end
    end

    def dependencies
      @dependencies ||= self.depends_on.collect { |dependency| AllPreloaders.instance.from_symbol(dependency) }
    end

    def all_dependencies
      @all_dependencies ||= (self.dependencies + (self.dependencies.collect { |d| d.all_dependencies }).flatten).uniq
    end
  end

  class PreloaderDataHash < Hash
    def []=(key, value)
      print "."
      super
    end
  end

end