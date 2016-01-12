require 'standupbot/sync'

class Api::StandupsController < Api::BaseController

  respond_to :html, :text, only: :start

  # GET /api/start
  def start
    @standup_sync = Standupbot::Sync.new

    if @standup_sync.valid?
      @standup_sync.perform
    else
      @errors = @standup_sync.errors
    end

    respond_with do |format|
      format.html
      format.text
    end
  end

end
