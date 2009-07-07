require 'active_support/deprecation'

module FactoryDataPreloader
  class PreloaderNotDefinedError < StandardError; end

  mattr_accessor :preload_all
  self.preload_all = true

  mattr_accessor :preload_types
  self.preload_types = []

  class << self
    alias :preload_all? :preload_all

    def requested_preloaders
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

  class Preloader
    attr_accessor :model_type, :model_class, :proc, :depends_on
    attr_reader   :data

    def initialize(model_type, model_class, proc, depends_on)
      model_class ||= model_type.to_s.pluralize.classify.constantize

      @model_type, @model_class, @proc, @depends_on = model_type, model_class, proc, [depends_on].compact.flatten
      AllPreloaders.instance << self

      DataMethods.class_eval do
        define_method model_type do |key|
          FactoryData.send(:get_record, model_type, key)
        end
      end
    end

    def preload!
      return if preloaded?
      @data = PreloadedDataHash.new(self)
      print "Preloading #{model_type}:"
      benchmark_measurement = Benchmark.measure { self.proc.try(:call, @data) }
      print "(#{format('%.3f', benchmark_measurement.real)} secs)\n"
    end

    def preloaded?
      !@data.nil?
    end

    def delete_table_data!
      unless @table_data_deleted
        self.model_class.delete_all
        @table_data_deleted = true
      end
    end

    def dependencies
      self.depends_on.collect { |dependency| AllPreloaders.instance.from_symbol(dependency) }
    end

    def all_dependencies
      (self.dependencies + (self.dependencies.collect { |d| d.all_dependencies }).flatten).uniq
    end

    def get_record(key)
      unless self.preloaded?
        raise DefinedPreloaderNotRunError.new, "The :#{self.model_type} preloader has never been run.  Did you forget to add the 'preload_factory_data :#{self.model_type}' declaration to your test case?  You'll need this at the top of your test case class if you want to use the factory data defined by this preloader."
      end

      unless record_id_or_error = self.data[key]
        raise PreloadedRecordNotFound.new, "Could not find a preloaded record #{self.model_type} recore for :#{key}.  Did you mispell :#{key}?"
      end

      if record_id_or_error.is_a?(Exception)
        raise ErrorWhilePreloadingRecord.new, "An error occurred while preloading #{self.model_type}(:#{key}): #{record_id_or_error.class.to_s}: #{record_id_or_error.message}\n\nBacktrace:\n\n#{record_id_or_error.backtrace}"
      end

      self.model_class.find_by_id(record_id_or_error)
    end

    def remove!
      preloader = self
      DataMethods.class_eval do
        remove_method(preloader.model_type) if method_defined?(preloader.model_type)
      end

      if @data
        self.model_class.delete_all(:id => @data.record_ids)
        @data = nil
      end

      AllPreloaders.instance.delete(self)
    end
  end

end