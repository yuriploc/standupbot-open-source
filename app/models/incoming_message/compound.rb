require_relative 'base'

class IncomingMessage
  class Compound < Base

    def initialize(message, standup)
      super(message, standup)

      @standup = channel.today_standups.where(user_id: reffered_user.id).first!

    rescue ActiveRecord::RecordNotFound
      raise InvalidCommand.new("<@#{user.slack_id}> Given user is not participating of today standup.")
    end

    def user
      User.where(slack_id: @message['user']).first
    end

    def reffered_user
      User.where(slack_id: @message['text'][/\<.*?\>/].gsub(/[<>@]/, '')).first
    end

    def valid?
      if reffered_user.blank?
        raise InvalidCommand.new("<@#{user.slack_id}> Given user does not exist in this channel.")
      end

      super
    end

  end
end
