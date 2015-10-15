require_relative 'base'

class IncomingMessage
  class Compound < Base

    def user
      User.where(slack_id: @message['text'][/\<.*?\>/].gsub(/[<>@]/, '')).first
    end

    def current_user
      User.where(slack_id: @message['user']).first
    end

  end
end
