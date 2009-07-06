require File.dirname(__FILE__) + '/test_helper'

class PreloadedDataHashTest < Test::Unit::TestCase
  def setup
    FactoryDataPreloader.reset!
  end

  def self.test_add_valid_record(desc, &block)
    context desc do
      setup do
        @out, @err = OutputCapturer.capture do
          @preloaded_data_hash.add(:record) { @user = instance_eval(&block) }
        end
      end

      should 'print a dot' do
        assert_equal '', @err
        assert_equal '.', @out
      end

      should 'add the record id to the hash' do
        assert_equal @user.id, @preloaded_data_hash[:record]
      end
    end
  end

  def self.test_add_invalid_record(desc, error_msg_regex, &block)
    context desc do
      setup do
        @out, @err = OutputCapturer.capture do
          @preloaded_data_hash.add(:record) { instance_eval(&block) }
        end
      end

      should 'print a warning message' do
        assert_equal '', @err
        assert_match /WARNING: an error occurred while preloading/, @out
      end

      should 'add an error message to the hash' do
        assert @preloaded_data_hash[:record].is_a?(Exception)
        assert_match error_msg_regex, @preloaded_data_hash[:record].message
      end
    end
  end

  context 'For a new preloader data hash' do
    setup do
      @preloaded_data_hash = PreloadedDataHash.new(stub_everything(:model_class => User))
    end

    test_add_valid_record('when a saved record is added') { User.create!(:first_name => 'Barack', :last_name => 'Obama') }
    test_add_valid_record('when a valid unsaved record is added') { User.new(:first_name => 'Barack', :last_name => 'Obama') }
    test_add_invalid_record('when an invalid unsaved record is added', /Error preloading factory data.*could not be saved/) { User.new }
    test_add_invalid_record('when an error occurs while adding the preloading a record', /This is an error/) { raise 'This is an error' }

    context 'adding a record through the deprecated []= method' do
      setup do
        @out, @err = OutputCapturer.capture do
          @preloaded_data_hash[:record] = (@user = User.create!(:first_name => 'Barack', :last_name => 'Obama'))
        end
      end

      should 'print a deprecation warning' do
        assert_equal '', @err
        assert_match /DEPRECATION WARNING: Instead of .* please use .*/, @out
      end

      should 'add the record id to the hash' do
        assert_equal @user.id, @preloaded_data_hash[:record]
      end
    end

    context 'when multiple records and errors have been added' do
      setup do
        @out, @err = OutputCapturer.capture do
          @preloaded_data_hash.add(:barack) { @barack = User.create!(:first_name => 'Barack', :last_name => 'Obama') }
          @preloaded_data_hash.add(:error)  { raise 'An error' }
          @preloaded_data_hash.add(:george) { @george = User.create!(:first_name => 'George', :last_name => 'Washington') }
        end
      end

      should 'return the record ids for #record_ids' do
        assert_same_elements [@barack.id, @george.id], @preloaded_data_hash.record_ids
      end
    end
  end
end