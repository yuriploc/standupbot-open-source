require 'rails_helper'

describe Standup do

  subject { build(:standup) }

  describe '.active' do
    let!(:active_standup)    { create(:standup, :active) }
    let!(:idle_standup)      { create(:standup, :idle) }
    let!(:completed_standup) { create(:standup, :completed) }
    let!(:answering_standup) { create(:standup, :answering) }

    it 'only includes active standups' do
      expect(described_class.active).to match_array([active_standup])
    end
  end

  describe '.by_date' do
    let(:standup_1) { create(:standup, created_at: 1.day.ago) }
    let(:standup_2) { create(:standup, created_at: 2.days.ago) }

    it 'returns the expected standups' do
      expect(described_class.by_date(1.day.ago.to_date)).to match_array([standup_1])
    end
  end

  describe 'delegates' do
    describe 'user' do
      it 'full_name' do
        expect(subject.user_full_name).to eq(subject.user.full_name)
      end

      it 'slack_id' do
        expect(subject.user_slack_id).to eq(subject.user.slack_id)
      end
    end

    describe 'channel' do
      it 'slack_id' do
        expect(subject.channel_slack_id).to eq(subject.channel.slack_id)
      end
    end
  end

end
