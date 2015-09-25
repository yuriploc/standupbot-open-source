class StandupController < ApplicationController

  def index
    @standups = Standup.all
  end

end
