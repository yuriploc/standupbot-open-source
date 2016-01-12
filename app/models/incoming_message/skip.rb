require_relative 'compound'

class IncomingMessage
  class Skip < Compound

    def execute
      super

      if @standup.active?
        @standup.skip!

        @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.skip', user: @standup.user_slack_id)
      end
    end

    def validate!
      if !user.admin?
        raise InvalidCommand.new("You don't have permission to skip this user.")
      elsif @standup.completed?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> has already completed standup today.")
      elsif @standup.answering?
        raise InvalidCommand.new("<@#{reffered_user.slack_id}> is doing his/her standup.")
      end

      super
    end

  end
end
