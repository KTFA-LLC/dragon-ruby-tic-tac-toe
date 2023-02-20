require "app/serializer.rb"
require "app/gameboard-configurator.rb"
require "app/gameplay.rb"
def do_create_online_tick args
    args.state.game_started ||= false
    if args.state.game_id
      play_online_game args
      return
    end
    if !args.state.game_started
        args.state.game_started = true
        json = serialize_object_to_json ({ board: args.state.board })
        args.state.start_game = $gtk.http_post_body "http://localhost:3000/tic-tac-toe", json, ["Content-Type: application/json", "Content-Length: #{json.length}"]
    end
    if !args.state.start_game.nil? && !args.state.game_id
        if args.state.start_game[:complete]
          if args.state.start_game[:http_response_code] == 201
            response = args.gtk.parse_json args.state.start_game[:response_data]
            args.state.game_id = response["game_id"]
            args.state.current_player = 'x'
            args.state.local_player = 'x'
            args.state.saved_board = response["board"]
          else
            args.gtk.reset
          end
        end
      end

end

def do_join_online_tick args
  if !args.state.game_id
    args.state.entered_game_id ||= ""
    args.state.error ||= ""
    args.outputs.labels << [640, 720, "Enter Game Id", 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 640, args.state.entered_game_id, 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 560, "Press enter to join", 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 500, "Error: #{args.state.error}", 10, 1, 255, 255, 255] if args.state.error != ""
    if args.inputs.keyboard.key_down.enter && !args.state.game_started
      args.state.game_started = true
      args.state.join_game = $gtk.http_post "http://localhost:3000/tic-tac-toe/join/#{args.state.entered_game_id}"
    else
      if args.inputs.text.length > 0 && !args.state.game_started && !args.state.join_game
        args.state.entered_game_id += args.inputs.text[0] 
      end
      if args.state.join_game && args.state.join_game[:complete]
        if args.state.join_game[:http_response_code] == 200
          response = args.gtk.parse_json args.state.join_game[:response_data]
          args.state.game_id = response["game_id"]
          args.state.current_player = response["current_player"]
          args.state.local_player = 'o'
          args.state.board = convert_array_of_hashes_to_symbols(response["board"])
        else
          args.state.error = args.state.join_game[:http_response_code]
          args.gtk.reset
        end
    end
  end
  else
    play_online_game args
  end
end

def play_online_game args
  args.outputs.labels << [640, 720, "Game ID: #{args.state.game_id}", 10, 1, 255, 255, 255]
  args.outputs.labels << [0, 720, "You are: #{args.state.local_player}", 10, 0, 255, 255, 255]
  args.outputs.labels << [1000, 720, "Turn is: #{args.state.current_player}", 10, 0, 255, 255, 255]
  game_condition = play args
  unless game_condition
    args.outputs.sprites << args.state.board.map do |box|
      box.player 
    end
    if args.state.current_player == args.state.local_player
      place_pieces_online args
    else
      get_board_online args
    end
  end
end

def get_board_online args
  args.state.get_debounce ||= 0
  if !args.state.get_game
    if args.state.get_debounce > 0
      args.state.get_debounce -= 1
    else
      args.state.get_game = $gtk.http_get "http://localhost:3000/tic-tac-toe/#{args.state.game_id}"
    end
  end
  if args.state.get_game && args.state.get_game[:complete]
    if args.state.get_game[:http_response_code] == 200
      response = args.gtk.parse_json args.state.get_game[:response_data]
      args.state.board = convert_array_of_hashes_to_symbols(response["board"])
      args.state.current_player = response["current_player"]
      args.outputs.sprites << args.state.board.map do |box|
        box.player 
      end
      args.state.get_game = nil
      args.state.get_debounce = 300
    else
      args.state.error = args.state.get_game[:http_response_code]
      args.gtk.reset
    end
  end
end

def place_pieces_online(args)
  if args.inputs.click && !args.state.update_game
      x_position = args.inputs.mouse.x
      y_position = args.inputs.mouse.y
      should_update = false
      args.state.board.each do |box|
        if x_position.between?(box[:begin_x], box[:end_x]) && y_position.between?(box[:begin_y], box[:end_y]) && !box.player
          box.player = {
            x: box[:begin_x] + 96,
            y: box[:begin_y],
            w: 240,
            h: 240,
            player: args.state.current_player,
            path: "sprites/player-#{args.state.current_player}.png",
          }
          should_update = true
        end
      end
      if should_update
        json = serialize_object_to_json ({ board: args.state.board })
        args.state.update_game = $gtk.http_post_body "http://localhost:3000/tic-tac-toe/turn/#{args.state.game_id}", json, ["Content-Type: application/json", "Content-Length: #{json.length}"] unless args.state.update_game
      end
    end
    if args.state.update_game && args.state.update_game[:complete]
      if args.state.update_game[:http_response_code] == 200
        response = args.gtk.parse_json args.state.update_game[:response_data]
        args.state.board = convert_array_of_hashes_to_symbols(response["board"])
        args.state.current_player = response["current_player"]
        args.state.update_game = nil
      else
        args.state.error = args.state.update_game[:http_response_code]
        args.gtk.reset
      end
    end
end