require 'sinatra'
require 'securerandom'

get '/tic-tac-toe/{id}' do
  return Cache.get(params[:id]).to_json
end

post '/tic-tac-toe/turn/{id}' do
  game_id = params[:id]
  request.body.rewind
  body = request.body.read
  request_payload = JSON.parse body if body
  game_object = Cache.get(game_id)
  game_object[:board] = request_payload['board']
  game_object[:current_player] = game_object[:current_player] == 'x' ? 'o' : 'x'
  Cache.set(game_id, game_object)
  return game_object.to_json
end



post '/tic-tac-toe' do
  game_id = get_game_id
  request.body.rewind
  body = request.body.read
  request_payload = JSON.parse body if body
  game_object = {board: request_payload['board'], current_player: 'x', game_id: game_id, game_joined: false}
  Cache.set(game_id, game_object)
  response.status = 201
  return game_object.to_json
end

def get_game_id
  id = SecureRandom.hex(3)
  return id if Cache.get(id).nil?
  get_game_id
end

post '/tic-tac-toe/join/{id}' do
  game_id = params[:id]
  game_object = Cache.get(game_id)
  if game_object.nil? || game_object[:game_joined]
    response.status = 404
    return {error: 'Game not found'}.to_json
  end
  response.status = 200
  game_object[:game_joined] = true
  Cache.set(game_id, game_object)
  return game_object.to_json
end

class Cache
  @@cache ||= {}

  def self.get(key)
    @@cache[key]
  end

  def self.set(key, value)
    @@cache[key] = value
  end

end

