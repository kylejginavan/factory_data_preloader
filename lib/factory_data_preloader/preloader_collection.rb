module FactoryDataPreloader
  class PreloaderCollection < Array
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

    def from_symbol(symbol)
      unless preloader = self.detect { |p| p.model_type == symbol }
        raise PreloaderNotDefinedError, "The preloader for :#{symbol} has not been defined."
      end
      preloader
    end
  end

  class AllPreloaders < PreloaderCollection
    include Singleton
  end

end