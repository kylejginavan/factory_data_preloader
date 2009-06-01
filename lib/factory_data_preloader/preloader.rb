module FactoryDataPreloader
  class PreloaderNotDefinedError < StandardError; end

  class Preloader
    attr_accessor :model_type, :model_class, :proc, :depends_on

    def initialize(model_type, model_class, proc, depends_on)
      @model_type, @model_class, @proc, @depends_on = model_type, model_class, proc, depends_on || []
      PreloaderCollection.instance << self
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
      @dependencies ||= begin
        self.depends_on.collect do |dependency|
          preloader = PreloaderCollection.instance.detect { |p| p.model_type == dependency }
          raise PreloaderNotDefinedError, "The preloader for :#{dependency} has not been defined." unless preloader
          preloader
        end
      end
    end
  end

  class PreloaderCollection < Array
    include Singleton

    def dependency_order
      unordered_preloaders = Array.new(self) # rather than using self.dup since singleton doesn't allow duping.
      ordered_preloaders = []

      until unordered_preloaders.empty?
        unordered_preloaders.each do |preloader|
          if preloader.dependencies.all? { |dependency| ordered_preloaders.include?(dependency) }
            ordered_preloaders << unordered_preloaders.delete(preloader)
          end
        end
      end

      ordered_preloaders
    end
  end

  class PreloaderDataHash < Hash
    def []=(key, value)
      print "."
      super
    end
  end

end