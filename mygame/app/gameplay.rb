def play args
  make_board(args)
  args.state.current_player ||= 'x'
  game_condition = check_for_winner(args.state.board)
  
  
  if game_condition
    args.outputs.labels << [640, 360, "Player #{game_condition.upcase} wins!"]
    args.state.condition = game_condition
    args.state.scene = "game_over"
    return
  end
  game_condition
end

def get_available_spaces board
  available_moves = []
    board.select.with_index do |box, index|
      if !box.player
        available_moves << index +=1
      end
      
    end
    available_moves
end


def place_pieces(args)
    if args.inputs.click
        x_position = args.inputs.mouse.x
        y_position = args.inputs.mouse.y
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
            args.state.current_player = args.state.current_player == 'x' ? 'o' : 'x'
          end
        end
      end
end

def check_for_winner(board)
    # Check for winner
    winning_combinations = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
    ]
    winning_combinations.each do |combination|
    return 'x' if combination.all? do |box|
        board[box].player&.player == 'x'
    end
    return 'o' if combination.all? do |box|
        board[box].player&.player == 'o'
    end
    end

    return 'draw' if board.all? do |box|
        box.player
    end
    return nil
end