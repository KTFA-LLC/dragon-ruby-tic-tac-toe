require "app/gameboard-configurator.rb"
require "app/gameplay.rb"
require "app/menu.rb"
require "app/online.rb"

def ai_tick args
  make_board(args)
  game_condition = play args 
  unless game_condition || args.state.current_player == 'o'
    place_pieces(args)
  else
    simple_board = args.state.board.map { |box| box.player&.player ? box.player.player : ' ' }
    optimal_move = best_move(simple_board)

    args.state.board[optimal_move].player = {
      x: args.state.board[optimal_move][:begin_x] + 96,
      y: args.state.board[optimal_move][:begin_y],
      w: 240,
      h: 240,
      player: args.state.current_player,
      path: "sprites/player-#{args.state.current_player}.png",
    }
    args.state.current_player = 'x'
  end
  #puts optimal_move(args.state.board, 'o') if args.state.current_player == 'o'
  args.outputs.sprites << args.state.board.map do |box|
    box.player 
  end 
end 

def local_tick args
  game_condition = play args 
  place_pieces(args) unless game_condition
  args.outputs.sprites << args.state.board.map do |box|
    box.player 
  end
end

def game_over_tick args
  args.outputs.labels << [640, 360, "Player #{args.state.condition.upcase} wins!", 10, 1, 255, 255, 255 ] unless args.state.condition == 'draw'
  args.outputs.labels << [640, 360, "It's a draw!", 10, 1, 255, 255, 255] if args.state.condition == 'draw'
  args.outputs.labels << [640, 320, "Click to restart", 10, 1, 255, 255, 255]
  if args.inputs.mouse.click
    $gtk.reset
  end
end

def menu_tick args
  do_menu_tick args
end

def create_online_tick args
  do_create_online_tick args
end

def join_online_tick args
  do_join_online_tick args
end

def online_tick args
  do_online_tick args
end

def tick args
  args.state.scene ||= "menu"
  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    path: "data/background.png",
  }
  send("#{args.state.scene}_tick", args)
end




WINNING_COMBINATIONS = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8],  # rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8],  # columns
  [0, 4, 8], [2, 4, 6]               # diagonals
]




def available_moves board
  board.each_index.select { |i| board[i] == " " }
end

def winner board
  WINNING_COMBINATIONS.each do |combination|
    values = combination.map { |index| board[index] }
    return "X" if values.all? { |value| value == "X" }
    return "O" if values.all? { |value| value == "O" }
  end
  nil
end

def minimax(depth, current_player, board)
  return 0.5 if available_moves(board).empty?
  the_winner = winner(board)
  return 0 if the_winner == "X"
  return 1 if the_winner== "O"
  

  if current_player == "O"
    best_value = -1
    available_moves(board).each do |move|
      board[move] = current_player
      value = minimax(depth + 1, "X",board)
      board[move] = " "
      best_value = [best_value, value].max
    end
  else
    best_value = 2
    available_moves(board).each do |move|
      board[move] = current_player
      value = minimax(depth + 1, "O", board)
      board[move] = " "
      best_value = [best_value, value].min
    end
  end

  best_value
end

def best_move(board)
  best_value = -1
  best_move = nil
  available_moves(board).each do |move|
    board[move] = "O"
    puts "Trying move #{move}"
    puts Time.now
    value = minimax(0, "X", board)
    board[move] = " "
    if value > best_value
      best_value = value
      best_move = move
    end
  end
  best_move
end



$gtk.reset 
  # args.outputs.sprites <<     {
  #   x: 640,
  #   y: 360,
  #   w: 128,
  #   h: 128,
  #   path: 'sprites/player-o.png',
  # } 