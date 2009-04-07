require File.dirname(__FILE__) + '/test_helper'

class PreloaderTest < Test::Unit::TestCase
  def setup
    FactoryDataPreloader::PreloaderCollection.instance.clear
  end

  context 'A new preloader' do
    setup do
      proc = lambda { |data|
        data[:thom] = User.create(:first_name => 'Thom', :last_name => 'York')
        data[:john] = User.create(:first_name => 'John', :last_name => 'Doe')
      }
      @preloader = FactoryDataPreloader::Preloader.new(:users, User, proc, [])
    end

    should 'return the preloaded data for #data' do
      data = @preloader.data
      assert_equal 'York', data[:thom].last_name
      assert_equal 'Doe',  data[:john].last_name
    end

    should 'be automatically added to the PreloaderCollection' do
      assert_equal [@preloader], FactoryDataPreloader::PreloaderCollection.instance
    end
  end

  context 'A preloader with dependencies' do
    setup do
      @comments = FactoryDataPreloader::Preloader.new(:comments, Comment, nil, [:users, :posts])
    end

    should 'raise PreloaderNotDefinedError for #dependencies if the preloader it depends on are not defined' do
      assert_raise FactoryDataPreloader::PreloaderNotDefinedError do
        @comments.dependencies
      end
    end

    context 'when the dependency preloaders have also been defined' do
      setup do
        @posts = FactoryDataPreloader::Preloader.new(:posts, Post, nil, [:users])
        @users = FactoryDataPreloader::Preloader.new(:users, User, nil, [])
      end

      should 'return the preloader objects for #dependencies' do
        assert_equal [@users, @posts], @comments.dependencies
      end
    end
  end

  context 'A series of preloaders, with dependencies,' do
    setup do
      @post_image_ratings  = FactoryDataPreloader::Preloader.new(:post_image_ratings,  PostImageRating, nil, [:post_images])
      @post_images         = FactoryDataPreloader::Preloader.new(:post_images,         PostImage,       nil, [:posts])
      @ip_addresses        = FactoryDataPreloader::Preloader.new(:ip_addresses,        IpAddress,       nil, [])
      @posts               = FactoryDataPreloader::Preloader.new(:posts,               Post,            nil, [:users])
      @users               = FactoryDataPreloader::Preloader.new(:users,               User,            nil, [])
    end

    should 'sort correctly for PreloaderCollection.instance.dependency_order' do
      expected = [@ip_addresses, @users, @posts, @post_images, @post_image_ratings]
      assert_equal expected.map(&:model_type), FactoryDataPreloader::PreloaderCollection.instance.dependency_order.map(&:model_type)
    end
  end
end