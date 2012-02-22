class User < ActiveRecord::Base
attr_accessible  :categories
  #attr_accessor :password
  #before_save :encrypt_password
  
  serialize :categories
  
  has_many :posts, :dependent => :destroy
  accepts_nested_attributes_for :posts, :allow_destroy => true, :reject_if => :all_blank
  
  #validates_confirmation_of :password
  #validates_presence_of :password, :on => :create
  #validates_presence_of :email
  #validates_uniqueness_of :email

  # follow a user
  def follow!(user)
    $redis.multi do
      $redis.sadd(self.redis_key(:following), user.id)
      $redis.sadd(user.redis_key(:followers), self.id)
    end
  end

  # unfollow a user
  def unfollow!(user)
    $redis.multi do
      $redis.srem(self.redis_key(:following), user.id)
      $redis.srem(user.redis_key(:followers), self.id)
    end
  end

  # users that self follows
  def followers
    user_ids = $redis.smembers(self.redis_key(:followers))
    User.where(:id => user_ids)
  end

  # users that follow self
  def following
    user_ids = $redis.smembers(self.redis_key(:following))
    User.where(:id => user_ids)
  end

  # users who follow and are being followed by self
  def friends
    user_ids = $redis.sinter(self.redis_key(:following), self.redis_key(:followers))
    User.where(:id => user_ids)
  end

  # does the user follow self
  def followed_by?(user)
    $redis.sismember(self.redis_key(:followers), user.id)
  end

  # does self follow user
  def following?(user)
    $redis.sismember(self.redis_key(:following), user.id)
  end

  # number of followers
  def followers_count
    $redis.scard(self.redis_key(:followers))
  end

  # number of users being followed
  def following_count
    $redis.scard(self.redis_key(:following))
  end

  # follow a category
  def fcategory(category)
    #c = Category.find(category)
    #cats = $redis.sadd(self.redis_key(:categories), c.to_json)
    #self.categories = cats.to_json
  end

  # follows categories
  def cfollows
    #category_ids = $redis.smembers(self.redis_key(:categories))
  end

  # helper method to generate redis keys
  def redis_key(str)
    "user:#{self.id}:#{str}"
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def self.from_omniauth(auth)
  
  #puts  "user new --- "+ User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
    puts "user new --- "+auth.to_s
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.id=auth["uid"]
     
           
    end
  end
  
end