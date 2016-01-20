require_relative 'compound'

class IncomingMessage
  class NotAvailable < Compound

    def execute
      super

      if @standup.active?
        @standup.not_available!

        channel.message("<@#{reffered_user.slack_id}> is not available.")
      end
    end

    def validate!
      if !user.admin?
        raise InvalidCommand.new("You don't have permission to set this user not available.")
      elsif @standup.idle?
        raise InvalidCommand.new("You need to wait until <@#{reffered_user.slack_id}> turns.")
      elsif @standup.completed?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> has already completed standup today.")
      elsif @standup.answering?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> is doing his/her standup.")
      end

      super
    end

  end
end
