require 'rubygems'
require 'shoulda'
require 'sqlite3'

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

module FactoryDataPreloader
  def self.reset!
    self.preload_all = true
    self.preload_types = []

    preloaders = Array.new(FactoryDataPreloader::AllPreloaders.instance)
    preloaders.each do |preloader|
      preloader.remove!
    end

    FactoryData.reset_cache!
  end
end

require 'lib/schema'
require 'lib/models'