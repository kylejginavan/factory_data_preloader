# TODO: add tests for this.  I've manually tested this in a Rails 2.2 and 2.3 app, but haven't found a way to add
# a test for this to our test suite.  It's difficult to test this since it just modifies what happens before the
# tests are run.

# Between Rails 2.2 and 2.3, the fixture loading code was moved from
# Test::Unit::TestCase to ActiveRecord::TestFixtures.  See this commit:
# http://github.com/rails/rails/commit/b0ee1bdf2650d7a8380d4e9be58bba8d9c5bd40e
patch_module = defined?(ActiveRecord::TestFixtures) ? ActiveRecord::TestFixtures : Test::Unit::TestCase

patch_module.class_eval do
  def load_fixtures_with_preloaded_factory_data
    val = load_fixtures_without_preloaded_factory_data
    FactoryData.preload_data!
    val
  end

  def teardown_fixtures_with_preloaded_factory_data
    FactoryData.reset_cache!
    teardown_fixtures_without_preloaded_factory_data
  end

  alias_method_chain :load_fixtures, :preloaded_factory_data
  alias_method_chain :teardown_fixtures, :preloaded_factory_data
end

# Fixtures#delete_existing_fixtures was removed in Rails 3.1
# see: https://github.com/rails/rails/commit/f9ea47736e270152c264bb5f8fdbfaa1d04fe82f
if ActiveRecord::Fixtures.instance_methods(false).include?(:delete_existing_fixtures)
  class Fixtures
    def delete_existing_fixtures_with_preloaded_factory_data
      delete_existing_fixtures_without_preloaded_factory_data
      FactoryData.delete_preload_data!
    end

    alias_method_chain :delete_existing_fixtures, :preloaded_factory_data
  end
end

class ActiveSupport::TestCase
  def self.preload_factory_data(*types)
    types.each { |t| FactoryDataPreloader.preload_types << t }
  end
end