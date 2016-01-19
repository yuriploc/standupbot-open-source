require 'rspec/mocks'

class SlackMock
  extend RSpec::Mocks::ExampleMethods

  def self.realtime_client
    client = Slack::RealTime::Client.new

    allow(client).to receive(:start!)
    allow(client).to receive(:stop!)

    client
  end

  def self.web_client
    client = Slack::Web::Client.new

    allow(client).to receive(:message)

    client
  end

  def self.setting
    Setting.first || FactoryGirl.create(:setting)
  end

end

