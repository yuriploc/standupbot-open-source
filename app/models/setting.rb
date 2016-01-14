# == Schema Information
#
# Table name: settings
#
#  id        :integer          not null, primary key
#  name      :string
#  bot_id    :string
#  bot_name  :string
#  web_url   :string
#  api_token :string
#

class Setting < ActiveRecord::Base

end
