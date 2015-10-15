require_relative 'simple'

class IncomingMessage
  class Edit < Simple

    def execute
      if @standup.editing
        @standup.process_answer(@message['text'])
        @standup.update_attributes(editing: false)

        @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.answer_saved')
        @client.message channel: @message['channel'], text: @standup.current_question

      else
        question_number = @message['text'].split('').last.try(:to_i)

        @standup.delete_answer_for(question_number)
        @standup.editing!

        case question_number
        when 1
          @client.message channel: @message['channel'], text: "1. What did you work on yesterday?"
        when 2
          @client.message channel: @message['channel'], text: "2. What are you working on today?"
        when 3
          @client.message channel: @message['channel'], text: "3. Is there anything in your way?"
        end
      end
    end

  end
end
