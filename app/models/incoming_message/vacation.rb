require_relative 'compound'

class IncomingMessage
  class Vacation < Compound

    def execute
      if current_user.admin?
        if @standup.complete?
          @client.message channel: @message['channel'], text: "<@#{user.slack_id}> has already completed standup today."

        else
          @standup.vacation!

          @client.message channel: @message['channel'], text: "<@#{user.slack_id}> has been put on vacation."

          if (standup = channel.pending_standups.first)
            standup.start!

            @client.message channel: @message['channel'],
                            text: I18n.t('activerecord.models.incoming_message.welcome', user: standup.user_slack_id)
          end
        end

      else
        @client.message channel: @message['channel'], text: "You don't have permission to vacation a user"
      end
    end

  end
end

