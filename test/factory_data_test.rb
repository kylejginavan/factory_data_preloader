require 'test_helper'

class FactoryData
  def self.reset!
    @@preloaders.reverse.each do |preloader|
      class << self; self; end.class_eval do 
        remove_method(preloader.model_type) 
      end
      
      unless @@preloaded_cache.nil?
        preloader.model_class.delete_all(:id => @@preloaded_cache[preloader.model_type].values)
      end
    end
    
    @@preloaded_cache = nil
    @@preloaded_data_deleted = nil
    @@single_test_cache = {}
    @@preloaders = []
  end
end

class FactoryDataTest < Test::Unit::TestCase  
  def teardown
    FactoryData.reset!
  end
  
  context 'Calling FactoryData.preload(:users)' do
    setup do
      FactoryData.preload(:users) do |data|
        data[:thom] = User.create(:first_name => 'Thom', :last_name => 'York')
      end
    end
    
    should_not_change 'User.count'
    should_change "FactoryData.methods.include?('users')", :from => false, :to => true
    
    should 'not allow it to be called again' do
      assert_raise PreloaderAlreadyDefinedError do
        FactoryData.preload(:users)
      end
    end
    
    context 'when there was a previous user record in the database' do
      setup { User.create(:first_name => 'Barack', :last_name => 'Obama') }
      
      context 'and calling FactoryData.delete_preload_data!' do
        setup { FactoryData.delete_preload_data! }
        should_change 'User.count', :to => 0
        
        context 'and there is another record in the database' do
          setup { User.create(:first_name => 'George', :last_name => 'Bush') }
          
          context 'and FactoryData.delete_preload_data! is called again' do
            setup { FactoryData.delete_preload_data! }
            should_not_change 'User.count'
          end
        end
      end
    end
    
    context 'and later calling FactoryData.preload_data!' do
      setup { FactoryData.preload_data! }
      
      should_change 'User.count', :by => 1
      
      context 'and later calling FactoryData.users(key)' do
        setup { @user = FactoryData.users(:thom) }
        
        should 'retrieve the correct user' do
          assert_equal 'Thom', @user.first_name
          assert_equal 'York', @user.last_name
          assert !@user.new_record?
        end
        
        should 'raise the appropriate error for a non-existant key' do
          assert_raise PreloadedRecordNotFound do
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
  
  context 'Preloading a record that cannot be saved to the database' do
    setup do
      @invalid_user = User.new(:first_name => 'Bob')
      assert !@invalid_user.valid?
      
      FactoryData.preload(:users) do |data|
        data[:bob] = @invalid_user
      end
    end
    
    should 'print an appropriate error message when preload_data! is called' do
      out, err = util_capture do
        FactoryData.preload_data!
      end
      
      assert_match /Error preloading factory data\.\s+User :bob could not be saved\.\s+Errors:\s+last_name can't be blank/im, out
    end
  end
  
  context 'Preloading multiple record types' do
    setup do
      FactoryData.preload(:users) do |data|
        data[:thom] = User.create(:first_name => 'Thom', :last_name => 'York')
        data[:john] = User.create(:first_name => 'John', :last_name => 'Doe')
      end
      
      FactoryData.preload(:posts) do |data|
        data[:tour] = FactoryData.users(:thom).posts.create(:title => 'Tour!', :body => 'Radiohead will tour soon.')
      end
      
      FactoryData.preload(:comments) do |data|
        data[:woohoo] = FactoryData.users(:john).comments.create(:post => FactoryData.posts(:tour), :comment => "I can't wait!")
      end
      
      FactoryData.preload_data!
    end
    
    should 'preload them in the defined order, allowing you to use prior definitions in later definitions' do
      assert_equal 'Thom', FactoryData.users(:thom).first_name
      assert_equal 'John', FactoryData.users(:john).first_name
      
      assert_equal FactoryData.users(:thom), FactoryData.posts(:tour).user
      
      assert_equal FactoryData.users(:john), FactoryData.comments(:woohoo).user
      assert_equal FactoryData.posts(:tour), FactoryData.comments(:woohoo).post
    end
  end
  
  private
  
  # borrowed from zentest assertions...
  def util_capture
    require 'stringio'
    orig_stdout = $stdout.dup
    orig_stderr = $stderr.dup
    captured_stdout = StringIO.new
    captured_stderr = StringIO.new
    $stdout = captured_stdout
    $stderr = captured_stderr
    yield
    captured_stdout.rewind
    captured_stderr.rewind
    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end
end