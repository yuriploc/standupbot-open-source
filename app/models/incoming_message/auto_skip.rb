class IncomingMessage
  class AutoSkip
    MAX_ATTEMPTS = 1

    # @param [Integer] standup_id The id of the standup that will be auto skipped.
    # @param [Date] standup_updated_at The last time the standup was updated.
    def initialize(standup_id, standup_updated_at)
      @standup_id         = standup_id
      @standup_updated_at = standup_updated_at
    end

    # If the users wasn't skipped yet, we automatically skip the user to have a more dinamic standup.
    def perform
      return unless needs_to_be_skipped?

      # TODO This logic is already in the app/models/incoming_message/skip.rb class,
      #   we need first to move all the slack client logic to a separate class and then reuse that logic.
      standup.skip!
      next_standup.init!

      skip_next_standup

      client.chat_postMessage(channel: standup.channel_slack_id,
                              text: I18n.t('activerecord.models.incoming_message.skip', user: standup.user_slack_id),
                              as_user: true)
      client.chat_postMessage(channel: standup.channel_slack_id,
                              text: I18n.t('activerecord.models.incoming_message.welcome', user: next_standup.user_slack_id),
                              as_user: true)
    end
    handle_asynchronously :perform, run_at: Proc.new { 1.minute.from_now }

    # @override
    #
    # If the job failed it won't be executed again.
    def max_attempts
      MAX_ATTEMPTS
    end

    private

    # Creates a new job to auto skip the next standup.
    def skip_next_standup
      AutoSkip.new(next_standup.id, next_standup.updated_at).perform
    end

    # Returns true only when given standup needs to be skipped automatically for us, otherwise returns false.
    #
    # @return [Boolean]
    def needs_to_be_skipped?
      standup.present? && next_standup.present? && standup.channel.active?
    end

    # @return [Standup]
    def standup
      @standup ||= Standup.active.where(id: @standup_id, updated_at: @standup_updated_at).first
    end

    # @return [Standup]
    def next_standup
      @next_standup ||= standup.channel.pending_standups.first
    end

    # @return [Slack::Web::Client]
    def client
      @client ||= Slack::Web::Client.new(token: Setting.first.try(:api_token))
    end

  end
end
