require File.dirname(__FILE__) + '/test_helper'

class FactoryDataTest < Test::Unit::TestCase
  context 'A new preloader' do
    setup do
      proc = lambda { |data| 
        data[:thom] = User.create(:first_name => 'Thom', :last_name => 'York')
        data[:john] = User.create(:first_name => 'John', :last_name => 'Doe')
      }
      @preloader = FactoryDataPreloader::Preloader.new(:users, User, proc, 0)
    end
    
    should 'return the preloaded data for #data' do
      data = @preloader.data
      assert_equal 'York', data[:thom].last_name
      assert_equal 'Doe',  data[:john].last_name
    end
  end
end