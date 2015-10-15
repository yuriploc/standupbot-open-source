require_relative 'simple'

class IncomingMessage
  class Delete < Simple

    def execute
      question_number = @message['text'].split('').last.try(:to_i)

      @standup.delete_answer_for(question_number)

      @client.message channel: @message['channel'], text: "Answer deleted"
    end

  end
end
