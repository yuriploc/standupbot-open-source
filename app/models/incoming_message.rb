class IncomingMessage

  delegate :yes?,
           :vacation?,
           :skip?,
           :postpone?,
           :quit?,
           :edit?,
           :delete?,
           :help?,
           :start?, to: :message_type

  # @param [Hash] message.
  # @option message [String] :type.
  # @option message [String] :channel.
  # @option message [String] :user.
  # @option message [String] :text.
  # @param [Slack::RealTime::Client] client.
  def initialize(message, client)
    @message = message
    @client  = client
  end

  # Executes incomming message.
  def execute
    return if standup.nil? && !start?

    Standup.vacation(@message, @client)      if vacation?
    Standup.admin_skip(@message, @client)    if skip?
    Standup.edit_question(@message, @client) if edit?
    Standup.delete_answer(@message, @client) if delete?

    quit_standup if quit?
    help         if help?

    if postpone? && !standup.try(:complete?)
      Standup.skip_until_last_standup(@client, @message, standup)
    else
      user_already_completed_standup if edit? && standup.try(:complete?)
      check_question_status          if !edit?
      start_standup                  if start? && standup.nil?
    end

    complete_standup if Standup.complete?(@client)
  end

  def help
    @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.help')
  end

  def start_standup
    @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.standup_started')
    @client.message channel: @message['channel'],
                    text: I18n.t('activerecord.models.incoming_message.welcome', user: @message['user'])

    Standup.check_registration(@client, @message, true)
  end

  def user_already_completed_standup
    if standup.editing
      save_edit_answer(client, @message, standup)
    else
      @client.message channel: @message['channel'],
                      text: I18n.t('activerecord.models.incoming_message.already_submitted', user: @message['user'])
    end
  end

  def save_edit_answer
    if standup.yesterday.nil?
      standup.update_attributes(yesterday: @message['text'])
    elsif standup.today.nil?
      standup.update_attributes(today: @message['text'])
    elsif standup.conflicts.nil?
      standup.update_attributes(conflicts: @message['text'])
    end

    standup.update_attributes(editing: false)

    @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.answer_saved')
  end

  def check_question_status
    if standup && !standup.complete? && user.not_ready? && yes?
      Standup.question_1(@client, @message, user) if standup && !standup.complete? && user.not_ready? && yes?
    elsif standup && !standup.complete? && user.ready?
      Standup.check_question(@client, @message, standup)
    end
  end

  def quit_standup
    @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.quit')

    @client.stop!
  end

  def complete_standup
    @client.message channel: @message['channel'], text: I18n.t('activerecord.models.incoming_message.resume')

    User.where(admin_user: true).first.update_attributes(admin_user: false) unless User.where(admin_user: true).first.nil?

    @client.stop!
  end

  private

  # @return [User]
  def user
    @user ||= User.find_by(user_id: @message['user'])
  end

  # @return [Standup]
  def standup
    @standup ||= Standup.check_for_standup(@message).first
  end

  # @return [Setting]
  def settings
    @settings ||= Setting.first
  end

  # @return [MessageType]
  def message_type
    @message_type ||= MessageType.new(@message['text'])
  end

end
