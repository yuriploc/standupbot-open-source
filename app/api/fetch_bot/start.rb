module FetchBot
  class Start < Grape::API
    get :start do
      client = Slack::RealTime::Client.new

      client.on :hello do
        puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
        puts "'#{client.self['name']}' What did you a"
        channel = client.channels.detect { |c| c['name'] == 'general' }['id']
        client.message channel: channel, text: '<!channel> Welcome to standup! Type "Fetch Standup" to get started.'
      end

      client.on :message do |data|
        standup = Standup.check_for_standup(data).first
        if Standup.complete?(client)
          client.message channel: data['channel'], text: "Standup is finished for the day, thanks!"
          client.stop!
        elsif data['text'] == "Good Luck Today!"
        elsif standup && data['text'] == "skip" && standup.not_complete?
          Standup.skip_standup(client, data, standup)
        elsif standup && standup.not_complete?
          Standup.check_question(client, data, standup)
        elsif data['text'] == 'fetch standup' && standup.nil?
          client.message channel: data['channel'], text: "<!channel> Welcome to standup!"
          Standup.check_registration(client, data)
        elsif standup && standup.complete?
          client.message channel: data['channel'], text: "You have already submitted a standup for today, thanks! <@#{data['user']}>"
          Standup.next_user
        end
      end

      client.start!
    end
  end
end
