require_relative 'simple'

class IncomingMessage
  class Help < Simple

    def execute
      super

      channel.message(I18n.t('activerecord.models.incoming_message.help'))
    end

  end
end

