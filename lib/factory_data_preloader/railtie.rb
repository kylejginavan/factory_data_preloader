module FactoryDataPreloader

  if defined? Rails::Railtie
    # Rails 3.x init
    class Railtie < Rails::Railtie
      config.after_initialize do
        FactoryData.definition_file_paths = [
          File.join(File.join(Rails.root.to_s, 'test', 'factory_data')),
          File.join(File.join(Rails.root.to_s, 'spec', 'factory_data')),
        ]

        FactoryData.find_definitions
      end
    end
  else
    # Rails 2.x init
    Rails.configuration.after_initialize do
      FactoryData.definition_file_paths = [
        File.join(RAILS_ROOT, 'test', 'factory_data'),
        File.join(RAILS_ROOT, 'spec', 'factory_data')
      ]

      FactoryData.find_definitions
    end
  end

end