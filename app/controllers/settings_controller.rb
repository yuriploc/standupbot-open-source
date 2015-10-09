class SettingsController < ApplicationController

  def index
    @settings = Setting.first
  end

  def update
    settings = Setting.find(params[:id])
    if settings.update(settings_params)
      redirect_to root_url, notice: "Success"
    else
      render :edit, notice: "There was an error"
    end
  end

  private

  def settings_params
    params.require(:setting).permit(:channel_type, :name, :bot_id)
  end

end
