require File.dirname(__FILE__) + '/test_helper'

class PreloaderTest < Test::Unit::TestCase
  def setup
    FactoryDataPreloader.reset!
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
      assert_equal [@preloader], FactoryDataPreloader::AllPreloaders.instance
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
      assert_equal expected.map(&:model_type), FactoryDataPreloader::AllPreloaders.instance.dependency_order.map(&:model_type)
    end

    should 'return the correct preloader objects for #all_dependencies' do
      assert_same_elements [@post_images, @posts, @users], @post_image_ratings.all_dependencies
      assert_same_elements [@posts, @users], @post_images.all_dependencies
      assert_same_elements [], @ip_addresses.all_dependencies
      assert_same_elements [@users], @posts.all_dependencies
      assert_same_elements [], @users.all_dependencies
    end

    context 'when FactoryDataPreloader.preload_all = true' do
      setup do
        FactoryDataPreloader.preload_all = true
      end

      should 'return all preloaders for FactoryDataPreloader.requested_preloaders' do
        expected = [@ip_addresses, @users, @posts, @post_images, @post_image_ratings]
        assert_equal expected.map(&:model_type), FactoryDataPreloader.requested_preloaders.dependency_order.map(&:model_type)
      end
    end

    context 'when FactoryDataPreloader.preload_all = false' do
      setup do
        FactoryDataPreloader.preload_all = false
      end

      should 'return no preloaders when for FactoryDataPreloader.requested_preloaders when preload_types is empty' do
        assert_equal [], FactoryDataPreloader.preload_types
        assert_equal [], FactoryDataPreloader.requested_preloaders
      end

      should 'return just the requested preloaders for FactoryDataPreloader.requested_preloaders' do
        FactoryDataPreloader.preload_types << :post_images
        FactoryDataPreloader.preload_types << :ip_addresses
        expected = [@ip_addresses, @users, @posts, @post_images]
        assert_equal expected.map(&:model_type), FactoryDataPreloader.requested_preloaders.dependency_order.map(&:model_type)
      end
    end
  end
end