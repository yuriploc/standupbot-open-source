class User < ActiveRecord::Base

  has_many :standups
  belongs_to :channel

  validates :slack_id, uniqueness: true

  scope :sort, -> { order('sort_order ASC') }

  class << self

    def registered?(id)
      User.where(slack_id: id).exists?
    end

  end

  def ready?
    self.standup_status == "ready"
  end

  def not_ready?
    self.standup_status == "not_ready"
  end

  def admin?
    self.admin_user
  end

end
