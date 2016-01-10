class StandupsController < ApplicationController

  # GET /
  def index
    @date     = Date.parse(params[:date]) rescue Date.today
    @standups = Standup.by_date(@date).sort_by { rand }
  end

end
