require 'test/unit'
require 'rubygems'

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
require 'factory_data_preloader/factory_data'
require 'factory_data_preloader/rails_core_ext'

if defined? Rails.configuration
  Rails.configuration.after_initialize do
    FactoryData.definition_file_paths = [
      File.join(RAILS_ROOT, 'test', 'factory_data'),
      File.join(RAILS_ROOT, 'spec', 'factory_data')
    ]
    FactoryData.find_definitions
  end
else
  FactoryData.find_definitions
end