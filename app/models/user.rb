class User < ActiveRecord::Base
  validates_uniqueness_of :user_id

  def self.registered?(id)
    User.find_by_user_id(id)
  end
end
