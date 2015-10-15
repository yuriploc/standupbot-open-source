class Standup < ActiveRecord::Base

  DISABLED    = 'disabled'
  IN_PROGRESS = 'in progress'
  COMPLETE    = 'complete'
  VACATION    = 'vacation'

  belongs_to :user
  belongs_to :channel

  validates :user_id, :channel_id, presence: true

  scope :for, -> user_id, channel_id { where(user_id: user_id, channel_id: channel_id) }
  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :completed, -> { where(status: [VACATION, COMPLETE]) }

  class << self

    # @param [Integer] user_id.
    # @param [Integer] channel_id.
    #
    # @return [Standup]
    def create_if_needed(user_id, channel_id)
      standup = Standup.today.for(user_id, channel_id).first_or_initialize

      standup.save

      standup
    end

  end

  # @return [Boolean]
  def complete?
    status == COMPLETE
  end

  # @return [Boolean]
  def in_progress?
    status == IN_PROGRESS
  end

  # @return [Boolean]
  def disabled?
    status == DISABLED
  end

  def current_question
    if self.yesterday.nil?
      Time.now.wday == 4 ? "1. What did you do on Friday?" : "1. What did you do yesterday?"

    elsif self.today.nil?
      "2. What are you working on today?"

    elsif self.conflicts.nil?
      "3. Is there anything standing in your way?"
    end
  end

  def process_answer(answer)
    if self.yesterday.nil?
      self.update_attributes(yesterday: answer)

    elsif self.today.nil?
      self.update_attributes(today: answer)

    elsif self.conflicts.nil?
      self.update_attributes(conflicts: answer)
      self.complete!
    end
  end

  def delete_answer_for(question)
    case question
    when 1
      self.update_attributes(yesterday: nil)
    when 2
      self.update_attributes(today: nil)
    when 3
      self.update_attributes(conflicts: nil)
    end
  end

  def skip!
    self.user.update_attributes(sort_order: user.sort_order + 1)
    self.delete
  end

  def editing!
    self.update_attributes(editing: true)
  end

  def start!
    self.update_attributes(status: IN_PROGRESS)
  end

  def complete!
    self.update_attributes(status: COMPLETE)
  end

  def vacation!
    self.update_attributes(status: "vacation", yesterday: "Vacation")
  end

  private

  def settings
    Setting.first
  end

end

