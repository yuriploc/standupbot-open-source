class Channel < ActiveRecord::Base

  has_many :users
  has_many :standups, through: :users

  state_machine initial: :idle do

    event :start do
      transition from: :idle, to: :active
    end

    event :stop do
      transition from: :active, to: :idle
    end

  end

  # Returns only the users that are able to do the standup.
  #
  # @return [ActiveRecord::AssociationRelation<Users>]
  def available_users
    self.users.non_bot.enabled
  end

  # Creates all the Standup records.
  #
  def start_today_standup!
    self.transaction do
      available_users.each_with_index do |user, index|
        standup = Standup.create_if_needed(user.id, self.id)

        standup.order= index + 1

        standup.save
      end
    end
  end

  # Returns all the standups of today.
  #
  # @return [ActiveRecord::AssociationRelation<Standup>]
  def today_standups
    self.standups.today
  end

  # Returns the standups that weren't done yet.
  #
  # @return [ActiveRecord::AssociationRelation<Standup>]
  def pending_standups
    today_standups.pending.sorted
  end

  # @return [Standup]
  def current_standup
    today_standups.in_progress.first
  end

  # @return [Boolean]
  def complete?
    available_users.count == today_standups.completed.count
  end

end

