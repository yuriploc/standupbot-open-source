require 'standupbot/sync'

class Api::StandupsController < Api::BaseController

  respond_to :html, only: :start

  # GET /api/start
  def start
    @standup_sync = Standupbot::Sync.new

    @standup_sync.async.perform if @standup_sync.valid?

    respond_with do |format|
      format.html
    end
  end

end
