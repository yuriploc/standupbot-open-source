class User < ActiveRecord::Base
  validates_uniqueness_of :user_id

  def ready?
    self.standup_status == "ready"
  end

  def not_ready?
    self.standup_status == "not_ready"
  end

  class << self
    def registered?(id)
      User.find_by_user_id(id)
    end

    def sort_users(non_complete_users)
      users = []
      register_users(non_complete_users)
      User.all.order("sort_order ASC").each do |user|
        if non_complete_users.include? user.user_id
          users << user.user_id
        end
      end
      users
    end

    def check_name(client, user)
      full_name = client.users.find { |what| what['id'] == user }["profile"]["real_name_normalized"]
      user = User.find_by_user_id(user)
      user.update_attributes(full_name: full_name) if user.full_name.nil?
    end

    def register_users(non_complete_users)
      non_complete_users.each do |user|
        User.create(user_id: user) unless registered?(user)
      end
    end
  end
end
