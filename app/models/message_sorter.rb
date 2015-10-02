class MessageSorter

  class << self
    def sort_incomming_messages(data, client)
      standup = Standup.check_for_standup(data).first
      user = User.find_by(user_id: data['user'])
      User.vacation(data, client) if data['text'].downcase.include? "vacation: <@"
      quit_standup(client, data['channel']) if data['text'].downcase == "quit-standup"
      complete_standup(client, data['channel']) if Standup.complete?(client)
      Standup.skip_until_last_standup(client, data, standup) if standup && data['text'].downcase == "skip" && standup.not_complete?
      user_already_completed_standup(client, data) if standup && standup.complete?
      check_question_status(client, data, user, standup)
      start_standup(client, data) if data['text'].downcase == 'start' && standup.nil?
    end

    def start_standup(client, data)
      client.message channel: data['channel'], text: "Standup has started."
      client.message channel: data['channel'], text: "Goodmorning <@#{data['user']}>, Welcome to daily standup! Are you ready to begin?  ('yes', or 'skip')"
      Standup.check_registration(client, data, true)
    end

    def user_already_completed_standup(client, data)
      client.message channel: data['channel'], text: "You have already submitted a standup for today, thanks! <@#{data['user']}>"
    end

    def check_question_status(client, data, user, standup)
      if standup && standup.not_complete? && user.not_ready? && data['text'].downcase == "yes"
        Standup.question_1(client, data, user) if standup && standup.not_complete? && user.not_ready? && data['text'].downcase == "yes"
      elsif standup && standup.not_complete? && user.ready?
        Standup.check_question(client, data, standup)
      end
    end

    def quit_standup(client, channel)
      client.message channel: channel, text: "Quiting Standup"
      client.stop!
    end

    def complete_standup(client, channel)
      channel = client.groups.detect { |c| c['name'] == 'standup-tester' }['id']
      client.message channel: channel, text: "That concludes our standup. For a recap visit http://quiet-shore-3330.herokuapp.com/"
      client.stop!
    end
  end
end
