class StandupsController < ApplicationController

  def index
    @standups = Standup.all.where(status: "complete")
  end

end
