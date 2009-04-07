class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  validates_presence_of :last_name
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many   :comments
  has_many   :post_images
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end

class PostImage < ActiveRecord::Base
  belongs_to :post
  has_many   :post_image_ratings
end

class PostImageRating < ActiveRecord::Base
  belongs_to :post_image
end

class IpAddress < ActiveRecord::Base
end