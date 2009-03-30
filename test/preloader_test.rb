require File.dirname(__FILE__) + '/test_helper'

class FactoryDataTest < Test::Unit::TestCase
  context 'A new preloader' do
    setup do
      proc = lambda { |data| 
        data[:thom] = User.create(:first_name => 'Thom', :last_name => 'York')
        data[:john] = User.create(:first_name => 'John', :last_name => 'Doe')
      }
      @preloader = FactoryDataPreloader::Preloader.new(:users, User, proc, 0, [])
    end
    
    should 'return the preloaded data for #data' do
      data = @preloader.data
      assert_equal 'York', data[:thom].last_name
      assert_equal 'Doe',  data[:john].last_name
    end
  end
  
  context 'Post and user preloaders, where post depends on users' do
    setup do
      @posts = FactoryDataPreloader::Preloader.new(:posts, Post, nil, 0, [:users])
      @users = FactoryDataPreloader::Preloader.new(:users, User, nil, 1, [])
    end
    
    should 'return a comparison value indicating that users is less than posts' do
      assert_equal -1, @users <=> @posts
      assert_equal  1, @posts <=> @users
    end
  end
  
  context 'Post and user preloaders, where neither post depends on the other' do
    setup do
      @posts = FactoryDataPreloader::Preloader.new(:posts, Post, nil, 0, [])
      @users = FactoryDataPreloader::Preloader.new(:users, User, nil, 1, [])
    end
    
    should 'return a comparison value based on their defined index' do
      assert_equal  1, @users <=> @posts
      assert_equal -1, @posts <=> @users
    end
  end
end