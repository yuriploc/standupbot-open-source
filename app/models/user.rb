class User < ActiveRecord::Base

  has_many :standups
  belongs_to :channel

  validates :slack_id, uniqueness: true

  class << self

    def admin
      find_by(admin: true)
    end

    def registered?(id)
      User.where(slack_id: id).exists?
    end

  end

  def mark_as_admin!
    self.update_attributes(admin: true)
  end

end
