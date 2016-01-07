class User < ActiveRecord::Base

  has_many :standups
  belongs_to :channel

  validates :slack_id, uniqueness: true

  scope :non_bot, -> { where(bot: false) }

  class << self

    def admin
      find_by(admin: true)
    end

    def registered?(id)
      User.where(slack_id: id).exists?
    end

    # Creates a user using given data from Slack.
    #
    # @param [Hash] data The data from the Slack API.
    # @return [User]
    def create_with_slack_data(data)
      user = User.where(slack_id: data['id']).first_or_initialize

      user.full_name= data['profile']['real_name_normalized']
      user.nickname= data['name']
      user.avatar_url= data['profile']['image_72']
      user.bot= (data['id'] == Setting.first.bot_id)

      user.save!

      user
    end

  end

  def mark_as_admin!
    self.update_attributes(admin: true)
  end

end
