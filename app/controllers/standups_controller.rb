class StandupsController < ApplicationController

  def index
    @standups = Standup.all
  end

end
