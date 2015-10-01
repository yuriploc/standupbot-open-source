class User < ActiveRecord::Base
  validates_uniqueness_of :user_id

  def self.registered?(id)
    User.find_by_user_id(id)
  end

  def ready?
    self.standup_status == "ready"
  end

  def not_ready?
    self.standup_status == "not_ready"
  end

  def self.sort_users(non_complete_users)
    users = []
    register_users(non_complete_users)
    User.all.order("sort_order ASC").each do |user|
      if non_complete_users.include? user.user_id
        users << user.user_id
      end
    end
    users
  end

  def self.vacation(data, client)
    user_id = data['text'][/\<.*?\>/].gsub(/[<>@]/, "")
    unless User.find_by_user_id(user_id)
      User.create(user_id: user_id)
      User.check_name(client, user_id)
    end
    if Standup.where(user_id: user_id, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, status: ["vacation", "complete"]).empty?
      Standup.create(user_id: user_id, status: "vacation")
      client.message channel: data['channel'], text: "<@#{user_id}> has been put on vacation."
      Standup.next_user
    else
      client.message channel: data['channel'], text: "<@#{user_id}> has already completed standup today."
    end
  end

  def self.check_name(client, user)
    full_name = client.users.find { |what| what['id'] == user }["profile"]["real_name_normalized"]
    user = User.find_by_user_id(user)
    user.update_attributes(full_name: full_name) if user.full_name.nil?
  end

  def self.register_users(non_complete_users)
    non_complete_users.each do |user|
      User.create(user_id: user) unless registered?(user)
    end
  end
end
