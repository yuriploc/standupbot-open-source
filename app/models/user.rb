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

    def vacation(data, client)
      user_id = data['text'][/\<.*?\>/].gsub(/[<>@]/, "")
      unless User.find_by_user_id(user_id)
        User.create(user_id: user_id)
        User.check_name(client, user_id)
      end
      standup = Standup.where(user_id: user_id, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).first
      if standup && standup.status == "complete"
        client.message channel: data['channel'], text: "<@#{user_id}> has already completed standup today."
      elsif standup
        standup.update_attributes(yesterday: "Vacation", status: "vacation")
        client.message channel: data['channel'], text: "<@#{user_id}> has been put on vacation."
        if Standup.complete?(client)
          channel = client.groups.detect { |c| c['name'] == 'standup-tester' }['id']
          client.message channel: data['channel'], text: "That concludes our standup. For a recap visit http://quiet-shore-3330.herokuapp.com/"
          client.stop!
        else
          Standup.next_user
        end
      else
        Standup.create(user_id: user_id, status: "vacation", yesterday: "Vacation")
        client.message channel: data['channel'], text: "<@#{user_id}> has been put on vacation."
        client.message channel: data['channel'], text: " <@#{data['user']}>, Welcome to daily standup! Are you ready to begin?  ('yes', or 'skip')"
        # Standup.next_user
      end
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
