require_relative 'compound'

class IncomingMessage
  class Vacation < Compound

    def execute
      super

      @standup.vacation!

      @client.message channel: @message['channel'], text: "<@#{reffered_user.slack_id}> has been put on vacation."
    end

    def validate!
      if !user.admin?
        raise InvalidCommand.new("You don't have permission to vacation a user.")
      elsif @standup.completed?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> has already completed standup today.")
      elsif @standup.answering?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> is doing his/her standup.")
      end

      super
    end

  end
end

