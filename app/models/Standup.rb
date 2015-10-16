class Standup < ActiveRecord::Base

  PENDING   = 'disabled'
  ACTIVE    = 'active'
  ANSWERING = 'answering'
  COMPLETE  = 'complete'
  VACATION  = 'vacation'
  NOT_AVAILABLE = "not_available"

  belongs_to :user
  belongs_to :channel

  validates :user_id, :channel_id, presence: true

  scope :for, -> user_id, channel_id { where(user_id: user_id, channel_id: channel_id) }
  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }

  scope :in_progress, -> { where(status: [ACTIVE, ANSWERING]) }
  scope :pending, -> { where(status: PENDING) }
  scope :completed, -> { where(status: [VACATION, COMPLETE]) }
  scope :completed, -> { where(status: [VACATION, COMPLETE, NOT_AVAILABLE]) }

  scope :sorted, -> { order(order: :asc) }

  delegate :slack_id, to: :user, prefix: true

  class << self

    # @param [Integer] user_id.
    # @param [Integer] channel_id.
    #
    # @return [Standup]
    def create_if_needed(user_id, channel_id)
      return if User.find(user_id).bot?

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
  def answering?
    status == ANSWERING
  end

  # @return [Boolean]
  def in_progress?
    [ACTIVE, ANSWERING].include?(status)
  end

  # @return [Boolean]
  def pending?
    status == PENDING
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
    maximum_order = (self.channel.today_standups.maximum(:order) + 1) || 1

    self.update_attributes(order: maximum_order, status: PENDING)
  end

  def editing!
    self.update_attributes(editing: true)
  end

  def start!
    self.update_attributes(status: ACTIVE)
  end

  def answering!
    self.update_attributes(status: ANSWERING)
  end

  def complete!
    self.update_attributes(status: COMPLETE)
  end

  def vacation!
    self.update_attributes(status: "vacation", yesterday: "Vacation")
  end

  def not_available!
    self.update_attributes(status: "not_available", yesterday: "Not Available")
  end

  private

  def settings
    Setting.first
  end

end
