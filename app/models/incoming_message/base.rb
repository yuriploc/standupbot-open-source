class IncomingMessage
  class Base

    def initialize(client, message, standup)
      @client  = client
      @message = message
      @standup = standup
    end

    def channel
      @standup.channel
    end

    def user
      raise 'Missing implementation #user'
    end

  end
end
