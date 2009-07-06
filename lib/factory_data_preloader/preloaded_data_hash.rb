class PreloadedDataHash
  attr_reader :preloader

  def initialize(preloader)
    @preloader, @backing_hash = preloader, {}
  end

  def []=(key, record)
    puts "DEPRECATION WARNING: Instead of 'data[:#{key}] = record' please use 'data.add(:#{key}) { record }'"
    add_to_backing_hash(key, record)
  end

  def [](key)
    @backing_hash[key]
  end

  def record_ids
    @backing_hash.values.select { |value| value.is_a?(Fixnum) }
  end

  def add(key)
    raise "You must pass a block to PreloaderDataHash#add.  You forgot to use the block in your #{preloader.model_type} prelodaer for the #{key.inspect} record." unless block_given?
    begin
      add_to_backing_hash(key, yield)
    rescue => e
      puts "WARNING: an error occurred while preloading the #{preloader.model_type.to_s}(:#{key}) record: #{e.class.to_s}: #{e.message}\n\nBacktrace: \n#{e.backtrace}\n\n"
      add_to_backing_hash(key, nil, e)
    end
  end

  private

  def add_to_backing_hash(key, record, error = nil)
    print '.'
    if record
      if record.new_record? && !record.save
        raise StandardError.new("Error preloading factory data.  #{preloader.model_class.to_s} :#{key.to_s} could not be saved.  Errors: #{pretty_error_messages(record)}")
      else
        @backing_hash[key] = record.id
      end
    else
      @backing_hash[key] = error
    end
  end

  # Borrowed from shoulda: http://github.com/thoughtbot/shoulda/blob/e02228d45a879ff92cb72b84f5fccc6a5f856a65/lib/shoulda/active_record/helpers.rb#L4-9
  def pretty_error_messages(obj)
    obj.errors.map do |a, m|
      msg = "#{a} #{m}"
      msg << " (#{obj.send(a).inspect})" unless a.to_sym == :base
    end
  end
end