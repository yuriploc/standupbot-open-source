require_relative 'compound'

class IncomingMessage
  class NotAvailable < Compound

    def execute
      if current_user.admin?
        if @standup.complete?
          @client.message channel: @message['channel'], text: "<@#{user.slack_id}> has already completed standup today."

        else
          @standup.not_available!
          @client.message channel: @message['channel'], text: "<@#{user.slack_id}> is not available."
        end

      else
        @client.message channel: @message['channel'], text: "You don't have permission to set this user not available."
      end
    end

  end
end
