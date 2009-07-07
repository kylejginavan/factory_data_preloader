require File.dirname(__FILE__) + '/test_helper'

class FactoryDataTest < Test::Unit::TestCase
  def setup
    FactoryDataPreloader.reset!
  end

  context 'Calling FactoryData.preload(:users)' do
    setup do
      FactoryData.preload(:users) do |data|
        data.add(:thom) { User.create(:first_name => 'Thom', :last_name => 'York') }
      end
    end

    should_not_change 'User.count'
    should_change "FactoryData.methods.include?('users')", :from => false, :to => true

    context 'when there was a previous user record in the database' do
      setup { User.create(:first_name => 'Barack', :last_name => 'Obama') }

      context 'and calling FactoryData.delete_preload_data!' do
        setup { FactoryData.delete_preload_data! }
        should_change 'User.count', :to => 0
      end
    end

    context 'and later calling FactoryData.preload_data!' do
      setup do
        @out, @err = OutputCapturer.capture do
          FactoryData.preload_data!
        end
      end

      should_change 'User.count', :by => 1

      context 'and later re-defining the preloaders' do
        setup do
          FactoryData.preload(:users) do |data|
            data.add(:thom) { User.create(:first_name => 'Thom', :last_name => 'York') }
            data.add(:john) { User.create(:first_name => 'John', :last_name => 'Doe') }
          end
        end

        should_change 'User.count', :by => -1

        context 'and preloading the re-defined preloader' do
          setup do
            @out, @err = OutputCapturer.capture do
              FactoryData.preload_data!
            end
          end

          should_change 'User.count', :by => 2
        end
      end

      context 'and later calling FactoryData.users(key)' do
        setup { @user = FactoryData.users(:thom) }

        should 'retrieve the correct user' do
          assert_equal 'Thom', @user.first_name
          assert_equal 'York', @user.last_name
          assert !@user.new_record?
        end

        should 'raise the appropriate error for a non-existant key' do
          assert_raise FactoryDataPreloader::PreloadedRecordNotFound do
            FactoryData.users(:not_a_user)
          end
        end

        should 'cache the record so as not to use User.find more than necessary' do
          User.expects(:find).never
          user2 = FactoryData.users(:thom)
          assert_equal @user.object_id, user2.object_id
        end

        context 'and later calling FactoryData.reset_cache!' do
          setup { FactoryData.reset_cache! }

          should 'reload the record from the database the next time FactoryData.users(key) is called' do
            User.expects(:find).once.returns(@user)
            FactoryData.users(:thom)
          end
        end
      end
    end
  end

  context 'Preloading with an explicit :model_class option' do
    setup do
      FactoryData.preload(:posts, :model_class => User) do |data|
        data.add(:george) { User.create(:first_name => 'George', :last_name => 'Washington') }
      end
      @out, @err = OutputCapturer.capture do
        FactoryData.preload_data!
      end
    end

    should 'use the passed model_class rather than inferring the class from the symbol' do
      assert_equal User, FactoryData.posts(:george).class
    end
  end

  context 'Preloading multiple record types, with dependencies' do
    setup do
      FactoryData.preload(:comments, :depends_on => [:users, :posts]) do |data|
        data.add(:woohoo) { FactoryData.users(:john).comments.create(:post => FactoryData.posts(:tour), :comment => "I can't wait!") }
      end

      FactoryData.preload(:posts, :depends_on => :users) do |data|
        data.add(:tour) { FactoryData.users(:thom).posts.create(:title => 'Tour!', :body => 'Radiohead will tour soon.') }
      end

      FactoryData.preload(:users) do |data|
        data.add(:thom) { User.create(:first_name => 'Thom', :last_name => 'York') }
        data.add(:john) { User.create(:first_name => 'John', :last_name => 'Doe') }
      end
    end

    should "raise the appropriate error when a developer tries to access a record that wasn't preloaded" do
      FactoryDataPreloader.preload_all = false
      FactoryDataPreloader.preload_types << :users

      @out, @err = OutputCapturer.capture do
        FactoryData.preload_data!
      end

      assert FactoryData.users(:thom)
      assert_raise FactoryDataPreloader::DefinedPreloaderNotRunError do
        FactoryData.posts(:tour)
      end
    end

    should 'preload them in the proper order, allowing you to use the dependencies' do
      @out, @err = OutputCapturer.capture do
        FactoryData.preload_data!
      end

      assert_equal 'Thom', FactoryData.users(:thom).first_name
      assert_equal 'John', FactoryData.users(:john).first_name

      assert_equal FactoryData.users(:thom), FactoryData.posts(:tour).user

      assert_equal FactoryData.users(:john), FactoryData.comments(:woohoo).user
      assert_equal FactoryData.posts(:tour), FactoryData.comments(:woohoo).post
    end
  end
end