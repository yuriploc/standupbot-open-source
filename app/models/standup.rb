# == Schema Information
#
# Table name: standups
#
#  id                 :integer          not null, primary key
#  yesterday          :text
#  today              :text
#  conflicts          :text
#  created_at         :datetime
#  updated_at         :datetime
#  channel_id         :integer
#  user_id            :integer
#  order              :integer          default(1)
#  state              :string
#  auto_skipped_times :integer          default(0)
#  reason             :string
#

class Standup < ActiveRecord::Base

  IDLE          = 'idle'
  ACTIVE        = 'active'
  ANSWERING     = 'answering'
  DONE          = 'done'
  NOT_AVAILABLE = 'not_available'
  VACATION      = 'vacation'

  MAXIMUM_AUTO_SKIPPED_TIMES = 3

  belongs_to :user
  belongs_to :channel

  validates :user_id, :channel_id, presence: true

  scope :for, -> user_id, channel_id { where(user_id: user_id, channel_id: channel_id) }
  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :by_date, -> date { where(created_at: date.at_midnight..date.next_day.at_midnight) }

  scope :in_progress, -> { where(state: [ACTIVE, ANSWERING]) }
  scope :active, -> { where(state: ACTIVE) }
  scope :pending, -> { where(state: IDLE) }
  scope :completed, -> { where(state: [DONE, NOT_AVAILABLE, VACATION]) }

  scope :sorted, -> { order(order: :asc) }

  delegate :slack_id, :full_name, to: :user, prefix: true
  delegate :slack_id, to: :channel, prefix: true

  state_machine initial: :idle do

    event :init do
      transition from: :idle, to: :active
    end

    event :skip do
      transition from: :active, to: :idle
    end

    event :start do
      transition from: :active, to: :answering
    end

    event :edit do
      transition from: :done, to: :answering
    end

    event :not_available do
      transition from: :active, to: :not_available
    end

    event :vacation do
      transition from: :active, to: :vacation
    end

    event :finish do
      transition from: :answering, to: :done
    end

    before_transition on: :skip do |standup, _|
      standup.order= (standup.channel.today_standups.maximum(:order) + 1) || 1
    end

  end

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
  def completed?
    done? || vacation? || not_available?
  end

  # @return [Boolean]
  def in_progress?
    active? || answering?
  end

  def question_for_number(number)
    case number
    when 1 then Time.now.wday == 4 ? "1. What did you do on Friday?" : "1. What did you do yesterday?"
    when 2 then "2. What are you working on today?"
    when 3 then "3. Is there anything standing in your way?"
    end
  end

  def current_question
    if self.yesterday.nil?
      Time.now.wday == 1 ? "<@#{self.user.slack_id}> 1. What did you do on Friday?" : "<@#{self.user.slack_id}> 1. What did you do yesterday?"

    elsif self.today.nil?
      "<@#{self.user.slack_id}> 2. What are you working on today?"

    elsif self.conflicts.nil?
      "<@#{self.user.slack_id}> 3. Is there anything standing in your way?"
    end
  end

  def process_answer(answer)
    answer = replace_slack_ids_for_names(answer)

    if self.yesterday.nil?
      self.update_attributes(yesterday: answer)

    elsif self.today.nil?
      self.update_attributes(today: answer)

    elsif self.conflicts.nil?
      self.update_attributes(conflicts: answer)
    end

    if self.yesterday.present? && self.today.present? && self.conflicts.present?
      self.finish!
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

  # Returns the current status of the standup.
  #
  # @return [String]
  def status
    if idle?
      "<@#{self.user.slack_id}> is in the queue waiting to do the standup."
    elsif active?
      "<@#{self.user.slack_id}> needs to answer if wants to do the standup."
    elsif answering?
      if yesterday.nil?
        "<@#{self.user.slack_id}> is answering what did yesterday."
      elsif today.nil?
        "<@#{self.user.slack_id}> is answering what's planning to do today."
      else
        "<@#{self.user.slack_id}> is answering if has any conflicts."
      end
    elsif completed?
      if vacation?
        "<@#{self.user.slack_id}> is on vacation."
      elsif not_available?
        "<@#{self.user.slack_id}> is not available."
      else
        "<@#{self.user.slack_id}> already did the standup."
      end
    end
  end

  private

  # Replaces all the Slack user ids with the name of those users.
  #
  # @param [String] text.
  # @return [String]
  def replace_slack_ids_for_names(text)
    return text if (user_ids = text.scan(/\<@(.*?)\>/)).blank?

    user_ids.each do |user_id|
      user = User.find_by_slack_id(user_id.first)

      text.gsub!("<@#{user_id.flatten.first}>", (user ? user.full_name : "User Not Available"))
    end

    text
  end

  def settings
    Setting.first
  end

end
