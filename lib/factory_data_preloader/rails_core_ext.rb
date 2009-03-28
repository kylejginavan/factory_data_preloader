# TODO: figure out why this doesn't work...

# class Test::Unit::TestCase
#   def load_fixtures_with_preloaded_factory_data
#     val = load_fixtures_without_preloaded_factory_data
#     FactoryData.preload_data!
#     val
#   end
#     
#   def teardown_fixtures_with_preloaded_factory_data
#     FactoryData.reset_cache
#     teardown_fixtures_without_preloaded_factory_data
#   end
# 
#   alias_method_chain :load_fixtures, :preloaded_factory_data
#   alias_method_chain :teardown_fixtures, :preloaded_factory_data
# end
# 
# class Fixtures
#   def delete_existing_fixtures_with_preloaded_factory_data
#     delete_existing_fixtures_without_preloaded_factory_data
#     FactoryData.delete_preload_data!
#   end
#   
#   alias_method_chain :delete_existing_fixtures, :preloaded_factory_data
# end