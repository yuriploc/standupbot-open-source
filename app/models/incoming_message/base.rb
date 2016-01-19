class IncomingMessage
  class Base

    class InvalidCommand < StandardError; end

    # @param [Hash] message The message we got from slack channel.
    # @option message [String] :type.
    # @option message [String] :channel.
    # @option message [String] :user.
    # @option message [String] :text.
    # @param [Standup] standup The current standup.
    def initialize(message, standup)
      @message = message
      @standup = standup
    end

    def execute
      self.validate!
    end

    # @return [Boolean]
    # @raise [InvalidCommand]
    def validate!
      true
    end

    def channel
      @standup.channel
    end

    def user
      raise 'Missing implementation #user'
    end

  end
end
