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
        end

      else
        @client.message channel: @message['channel'], text: "You don't have permission to vacation a user"
      end
    end

  end
end

