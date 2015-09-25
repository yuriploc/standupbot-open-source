module FetchBot
  class Start < Grape::API
    get :start do
      client = Slack::RealTime::Client.new
      binding.pry

      client.on :hello do
        puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
        puts "'#{client.self['name']}' What did you a"
      end

      client.on :message do |data|
        tester = Standup.check_for_standup(data).first
        if tester && tester.not_complete?
          Standup.continue_standup(client, data, tester)
        elsif data['text'] == 'fetch standup' && tester.nil?
          Standup.check_registration(client, data)
        elsif tester.complete?
          client.message channel: data['channel'], text: "You have already submitted a standup for today, thanks! <@#{data['user']}>"
        end
      end

      client.start!
    end
  end
end
