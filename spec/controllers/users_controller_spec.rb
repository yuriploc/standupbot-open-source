require 'rails_helper'

describe UsersController do

  describe 'GET \'index\'' do
    let!(:bot_user) { create(:user, :bot) }
    let!(:user)     { create(:user) }

    render_views

    it 'renders the correct partial' do
      get :index

      expect(response).to render_template('index')
    end

    it 'does not include bot users' do
      get :index

      expect(assigns[:users]).to match_array([user])
    end
  end

end
