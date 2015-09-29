class Standup < ActiveRecord::Base

  class << self
    def check_registration(client, data)
      unless User.registered?(data['user'])
        full_name = client.users.find { |what| what['id'] == data['user'] }["profile"]["real_name_normalized"]
        User.create(user_id: data['user'], full_name: full_name)
      end
      being_standup(client, data)
    end

    def being_standup(client, data)
      Standup.create(user_id: data['user'], created_at: Time.now)
      question_1(client, data)
    end

    def skip_standup(client, data, standup)
      standup.update_attributes(yesterday: "Skipped", today: "Skipped", conflicts: "Skipped", status: "complete")
      client.message channel: data['channel'], text: "Gotcha, enjoy your day!"
      next_user
    end

    def question_1(client, data)
      client.message channel: data['channel'], text: "Goodmorning <@#{data['user']}>, Welcome to daily standup!"
      client.message channel: data['channel'], text: "What did you do yesterday?"
    end

    def check_for_standup(data)
      Standup.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, user_id: data['user'])
    end

    def first_standup?
      Standup.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).empty?
    end

    def check_question(client, data, current_standup)
      if current_standup.yesterday.nil?
        yesterday(current_standup, client, data)
      elsif current_standup.today.nil?
        today(current_standup, client, data)
      elsif current_standup.conflicts.nil?
        conflicts(current_standup, client, data)
      end
    end

    def next_user
      client = Slack::Web::Client.new
      channel = client.groups_list['groups'].detect { |c| c['name'] == 'standup' }
      users = channel['members']
      non_complete_users = []
      users.each do |user|
        unless user == "U0B98TRHN"
          non_complete_users << user if Standup.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, user_id: user).empty?
        end
      end
      client = Slack::RealTime::Client.new
      unless non_complete_users.empty?
        data = {}
        data['channel'] = channel['id']
        data['user'] = non_complete_users.first
        client = Slack::RealTime::Client.new
        client.start!
        check_registration(client, data)
      end
    end

    def complete?(client)
      channel = client.channels.detect { |c| c['name'] == 'general' }
      users = channel['members']
      standups = Standup.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, status: "complete")
      users.count - 1 == standups.count
    end

    def yesterday(standup, client, data)
      standup.update_attributes(yesterday: data['text'])
      client.message channel: data['channel'], text: "What are you working on today?"
    end

    def today(standup, client, data)
      standup.update_attributes(today: data['text'])
      client.message channel: data['channel'], text: "Is there anything standing in your way?"
    end

    def conflicts(standup, client, data)
      standup.update_attributes(conflicts: data['text'], status: "complete")
      client = Slack::Web::Client.new
      channel = client.groups_list['groups'].detect { |c| c['name'] == 'standup' }
      client.chat_postMessage(channel: channel['id'], text: 'Good Luck Today!', as_user: true)
      next_user
    end
  end

  def not_complete?
    status != "complete"
  end

  def complete?
    status == "complete"
  end
end
