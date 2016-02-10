class AppAuth < Rack::Auth::Basic

  def call(env)
    request = Rack::Request.new(env)

    if request.path === '/api/standups/start'
      @app.call(env)
    else
      super
    end
  end
end
