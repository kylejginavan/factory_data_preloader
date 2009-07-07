require File.dirname(__FILE__) + '/test_helper'

class PreloaderTest < Test::Unit::TestCase
  def setup
    FactoryDataPreloader.reset!
  end

  context 'A new preloader' do
    setup do
      proc = lambda { |data|
        data.add(:thom) { User.create(:first_name => 'Thom', :last_name => 'York') }
        data.add(:john) { User.create(:first_name => 'John', :last_name => 'Doe') }
      }
      @preloader = FactoryDataPreloader::Preloader.new(:users, User, proc, [])
    end

    should 'be automatically added to the PreloaderCollection' do
      assert_equal [@preloader], FactoryDataPreloader::AllPreloaders.instance
    end

    context 'when preloaded' do
      setup do
        @out, @err = OutputCapturer.capture do
          @preloader.preload!
        end
      end

      should_change 'User.count', :by => 2

      should 'return the preloaded data when #get_record is called' do
        assert_equal 'York', @preloader.get_record(:thom).last_name
        assert_equal 'Doe',  @preloader.get_record(:john).last_name
      end

      should 'print out a preloader message, a dot for each record and a benchmark' do
        assert_equal '', @err
        assert_match /Preloading users:\.\.\([\d\.]+ secs\)/, @out
      end

      context 'when preloaded again' do
        setup do
          @out, @err = OutputCapturer.capture do
            @preloader.preload!
          end
        end

        should 'print nothing' do
          assert_equal '', @err
          assert_equal '', @out
        end

        should_not_change 'User.count'
      end

      should 'issue a delete statement if #delete_table_data! is called' do
        User.expects(:delete_all).once
        @preloader.delete_table_data!
      end

      context 'when #delete_table_data! is called' do
        setup do
          @preloader.delete_table_data!
        end

        should 'not issue another delete statement if #delete_table_data! is later called on the same preloader' do
          User.expects(:delete_all).never
          @preloader.delete_table_data!
        end
      end
    end
  end

  context 'A new preloader for email_addresses' do
    setup do
      @preloader = FactoryDataPreloader::Preloader.new(:email_addresses, nil, lambda { }, [])
    end

    should 'infer the model class' do
      assert_equal EmailAddress, @preloader.model_class
    end
  end

  context 'A preloader with errors' do
    setup do
      proc = lambda { |data|
        data.add(:thom) { raise StandardError('Error for thom') }
        data.add(:john) { @john = User.create(:first_name => 'John', :last_name => 'Doe') }
      }
      @preloader = FactoryDataPreloader::Preloader.new(:users, User, proc, [])
      @out, @err = OutputCapturer.capture do
        @preloader.preload!
      end
    end

    should 'raise an exception when the record with the error is accessed' do
      assert_raise FactoryDataPreloader::ErrorWhilePreloadingRecord do
        @preloader.get_record(:thom)
      end
    end

    should 'allow the error-free records to be accessed, even when they were created after the error record' do
      assert_equal @john, @preloader.get_record(:john)
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