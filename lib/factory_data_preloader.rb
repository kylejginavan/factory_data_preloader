require 'rubygems'
require 'singleton'

if ENV['RAILS_VERSION']
  puts "loading Rails version #{ENV['RAILS_VERSION']}"
  gem "activesupport", "= #{ENV['RAILS_VERSION']}"
  gem "activerecord", "= #{ENV['RAILS_VERSION']}"
end

require 'active_support'
require 'active_record'
require 'active_record/fixtures'

require 'factory_data_preloader/core_ext'
require 'factory_data_preloader/preloader'
require 'factory_data_preloader/preloader_collection'
require 'factory_data_preloader/preloaded_data_hash'
require 'factory_data_preloader/factory_data'
require 'factory_data_preloader/rails_core_ext'

require 'factory_data_preloader/railtie' if defined?(Rails)

