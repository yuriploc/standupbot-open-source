class Channel < ActiveRecord::Base

  has_many :users
  has_many :standups, through: :users

  def pending_users
    non_complete_users = self.users.select do |user|
      next if user.bot?

      Standup.today.for(user.id, self.id).empty?
    end

    User.where(id: non_complete_users).sort
  end

  # @return [Boolean]
  def complete?
    today_standups = standups.today.completed

    (users.count - 1) == today_standups.count
  end

end

