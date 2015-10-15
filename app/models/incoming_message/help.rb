require_relative 'simple'

class IncomingMessage
  class Help < Simple

    def execute
      @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.help')
    end

  end
end

