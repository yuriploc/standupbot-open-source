require_relative 'compound'

class IncomingMessage
  class Skip < Compound

    def execute
      if current_user.admin? || user.nil?
        @standup.skip!

        @client.message channel: @message['channel'], text: "I'll get back to you at the end of standup."

        if (standup = channel.pending_standups.first)
          standup.start!

          @client.message channel: @message['channel'],
                          text: I18n.t('activerecord.models.incoming_message.welcome', user: standup.user_slack_id)
        end

      else
        @client.message channel: @message['channel'], text: "You don't have permission to vacation a user"
      end
    end

  end
end
