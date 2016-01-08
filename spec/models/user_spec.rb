require 'rails_helper'

describe User do

  describe '.non_bot' do
    let(:bot)   { create(:user, :bot) }
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }

    it 'does not include bot users' do
      expect(described_class.non_bot).to_not include(bot)
    end

    it 'includes admin users' do
      expect(described_class.non_bot).to include(admin)
    end

    it 'includes default users' do
      expect(described_class.non_bot).to include(user)
    end
  end

end
