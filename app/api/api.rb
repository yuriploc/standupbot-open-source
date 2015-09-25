class API < Grape::API
  prefix 'api'
  format :json
  # mount FetchBot::Ping
  # mount FetchBot::Raise
  # mount FetchBot::GetStandup
  mount FetchBot::Start
end
