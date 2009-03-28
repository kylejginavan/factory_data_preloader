class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  validates_presence_of :last_name
end

class Post < ActiveRecord::Base
  belongs_to :user
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end