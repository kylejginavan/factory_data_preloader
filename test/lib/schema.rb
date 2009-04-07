OutputCapturer.capture do
  ActiveRecord::Schema.define do
    create_table :users, :force => true do |t|
      t.string   :first_name
      t.string   :last_name
      t.timestamps
    end
  end

  ActiveRecord::Schema.define do
    create_table :posts, :force => true do |t|
      t.references :user
      t.string     :title
      t.string     :body
      t.timestamps
    end
  end

  ActiveRecord::Schema.define do
    create_table :comments, :force => true do |t|
      t.references :user
      t.references :post
      t.string     :comment
      t.timestamps
    end
  end

  ActiveRecord::Schema.define do
    create_table :post_images, :force => true do |t|
      t.references :post
      t.timestamps
    end
  end

  ActiveRecord::Schema.define do
    create_table :post_image_ratings, :force => true do |t|
      t.references :post_image
      t.timestamps
    end
  end

  ActiveRecord::Schema.define do
    create_table :ip_addresses, :force => true do |t|
      t.string     :ip_address
      t.timestamps
    end
  end
end