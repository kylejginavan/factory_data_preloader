require 'rubygems'
require 'test/unit'
require 'shoulda'

begin
  require 'ruby-debug'
  Debugger.start
  Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
end


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'factory_data_preloader'

ActiveRecord::Base.establish_connection({ :database => ":memory:", :adapter => 'sqlite3', :timeout => 500 })

module OutputCapturer
  # borrowed from zentest assertions...
  def self.capture
    require 'stringio'
    orig_stdout = $stdout.dup
    orig_stderr = $stderr.dup
    captured_stdout = StringIO.new
    captured_stderr = StringIO.new
    $stdout = captured_stdout
    $stderr = captured_stderr
    yield
    captured_stdout.rewind
    captured_stderr.rewind
    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end
end

class FactoryDataPreloader::FactoryData
  # helper method to reset the factory data between test runs.
  def self.reset!
    @@preloaders.reverse.each do |preloader|
      class << self; self; end.class_eval do 
        remove_method(preloader.model_type) 
      end
      
      unless @@preloaded_cache.nil?
        preloader.model_class.delete_all(:id => @@preloaded_cache[preloader.model_type].values)
      end
    end
    
    @@preloaded_cache = nil
    @@preloaded_data_deleted = nil
    @@single_test_cache = {}
    @@preloaders = []
  end
end

require 'lib/schema'
require 'lib/models'