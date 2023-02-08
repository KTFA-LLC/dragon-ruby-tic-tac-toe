require 'sinatra'
before do
  next if request.get?
  request.body.rewind
  @request_payload = JSON.parse request.body.read
  puts @request_payload
end
get '/' do
  'Hello world!'
end

get '/tic-tac-toe/{id}' do
  return Cache.get(params[:id].to_i).to_json
end

put '/tic-tac-toe/{id}' do
  game_id = params[:id].to_i
  Cache.set(game_id, {board: @request_payload['board']})
  return Cache.get(game_id).to_json
end

post '/tic-tac-toe' do
  game_id = 1
  Cache.set(game_id, {board: @request_payload['board']})
  return game_id.to_json
end

class Cache
  @@cache ||= []

  def self.get(key)
    @@cache[key]
  end

  def self.set(key, value)
    @@cache[key] = value
  end

end

