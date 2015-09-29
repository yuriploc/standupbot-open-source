module FetchBot
  class Start < Grape::API
    get :start do
      client = Slack::RealTime::Client.new

      client.on :hello do
        puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
        channel = client.groups.detect { |c| c['name'] == 'standup' }['id']
        client.message channel: channel, text: 'Welcome to standup! Type "Start" to get started.'
      end

      client.on :message do |data|
        standup = Standup.check_for_standup(data).first
        if data['text'] == "quit-standup"
          client.message channel: data['channel'], text: "Quiting Standup"
          client.stop!
        elsif Standup.complete?(client)
          channel = client.groups.detect { |c| c['name'] == 'standup' }['id']
          client.message channel: data['channel'], text: "That concludes our standup. For a recap visit http://quiet-shore-3330.herokuapp.com/"
          client.stop!
        elsif data['text'] == "Good Luck Today!"
        elsif standup && data['text'] == "skip" && standup.not_complete?
          Standup.skip_standup(client, data, standup)
        elsif standup && standup.not_complete?
          Standup.check_question(client, data, standup)
        elsif data['text'] == 'Start' && standup.nil?
          Standup.check_registration(client, data)
        elsif standup && standup.complete?
          client.message channel: data['channel'], text: "You have already submitted a standup for today, thanks! <@#{data['user']}>"
        end
      end

      client.start!
    end
  end
end
