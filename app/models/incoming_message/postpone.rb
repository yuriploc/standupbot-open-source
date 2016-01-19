require_relative 'simple'

class IncomingMessage
  class Postpone < Simple

    def execute
      super

      @standup.skip!

      channel.message(I18n.t('activerecord.models.incoming_message.skip', user: @standup.user_slack_id))
    end

    def validate!
      if !@standup.active?
        raise InvalidCommand.new("You can only skip the standup when asked.")
      end

      super
    end

  end
end
