require_relative 'simple'

class IncomingMessage
  class Postpone < Simple

    def execute
      @standup.skip!

      @client.message channel: @message['channel'], text: "I'll get back to you at the end of standup."

      if (user = channel.pending_users.first)
        @client.message channel: @message['channel'],
                        text: I18n.t('activerecord.models.incoming_message.welcome', user: user.slack_id)
      end
    end

  end
end
