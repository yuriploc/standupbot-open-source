class API < Grape::API
  prefix 'api'
  format :json
  mount FetchBot::Start
end
