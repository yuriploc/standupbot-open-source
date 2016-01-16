require 'rails_helper'

describe IncomingMessage::AutoSkip do

  let!(:setting) { create(:setting) }
  let!(:channel) { create(:channel, :active) }

  let!(:current_standup) { create(:standup, :active, channel: channel, order: 1) }
  let!(:next_standup)    { create(:standup, :idle, channel: channel, order: 2) }

  let(:standup_id)         { current_standup.id }
  let(:standup_updated_at) { current_standup.updated_at }

  subject { described_class.new(standup_id, standup_updated_at) }

  before do
    channel.users << current_standup.user
    channel.users << next_standup.user

    allow(subject).to receive(:skip_next_standup).and_return(double(:auto_skip).as_null_object)
    allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).and_return(double(:slack).as_null_object)
  end

  describe '#perform' do
    context 'when given standup id does not exist' do
      let(:standup_id) { -1 }

      it 'returns nil' do
        expect(subject.perform.invoke_job).to be_nil
      end

      it 'does not send a message to a slack channel' do
        expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)

        subject.perform.invoke_job
      end
    end

    context 'when given stanup exist' do
      context 'and it was updated after the job was created' do
        let(:standup_updated_at) { Time.now }

        it 'returns nil' do
          expect(subject.perform.invoke_job).to be_nil
        end

        it 'does not send a message to a slack channel' do
          expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)

          subject.perform.invoke_job
        end
      end

      context 'and the state is answering' do
        let!(:current_standup) { create(:standup, :answering, channel: channel, order: 1) }

        it 'returns nil' do
          expect(subject.perform.invoke_job).to be_nil
        end

        it 'does not send a message to a slack channel' do
          expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)

          subject.perform.invoke_job
        end
      end

      context 'and the state is completed' do
        let!(:current_standup) { create(:standup, :completed, channel: channel, order: 1) }

        it 'returns nil' do
          expect(subject.perform.invoke_job).to be_nil
        end

        it 'does not send a message to a slack channel' do
          expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)

          subject.perform.invoke_job
        end
      end

      context 'and the state is idle' do
        let!(:current_standup) { create(:standup, :idle, channel: channel, order: 1) }

        it 'returns nil' do
          expect(subject.perform.invoke_job).to be_nil
        end

        it 'does not send a message to a slack channel' do
          expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)

          subject.perform.invoke_job
        end
      end

      context 'and the state is active' do
        let!(:current_standup) { create(:standup, :active, channel: channel, order: 1) }

        it 'changes the state of current standup to idle' do
          subject.perform

          expect(current_standup.reload.state).to eq(Standup::IDLE)
        end

        it 'changes the state of next standup to active' do
          subject.perform

          expect(next_standup.reload.state).to eq(Standup::ACTIVE)
        end

        it 'sends 2 messages to slack' do
          expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).
            with(channel: current_standup.channel_slack_id, text: kind_of(String), as_user: true)

          subject.perform
        end
      end
    end
  end

end
