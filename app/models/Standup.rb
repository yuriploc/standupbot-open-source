class Standup < ActiveRecord::Base

  class << self
    def check_registration(client, data)
      if User.registered?(data['user'])
        # client.message channel: data['channel'], text: "Welcome back <@#{data['user']}>!"
        being_standup(client, data)
      else
        User.create(user_id: data['user'])
        client.message channel: data['channel'], text: "Welcome to standup <@#{data['user']}> you have been registered!"
        begin_standup(client, data)
      end
    end

    def being_standup(client, data)
      Standup.create(user_id: data['user'], created_at: Time.now)
      client.message channel: data['channel'], text: "Goodmorning, Welcome to daily standup!"
      client.message channel: data['channel'], text: "What did you do yesterday?"
    end

    def check_for_standup(data)
      Standup.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, user_id: data['user'])
    end

    def continue_standup(client, data, current_standup)
      if current_standup.yesterday.nil?
        current_standup.update_attributes(yesterday: data['text'])
        client.message channel: data['channel'], text: "What are you working on today?"
      elsif current_standup.today.nil?
        current_standup.update_attributes(today: data['text'])
        client.message channel: data['channel'], text: "Is there anything standing in your way?"
      elsif current_standup.conflicts.nil?
        current_standup.update_attributes(conflicts: data['text'], status: "complete")
        client.message channel: data['channel'], text: "Good luck today!"
      end
    end
  end

  def not_complete?
    status != "complete"
  end

  def complete?
    status == "complete"
  end
end
