def do_menu_tick args
    args.state.menu_item_selected ||= 0
    check_positions_y = [320, 280, 240]
    args.outputs.labels << [640, 650, "Tic Tac Dragon's Toe", 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 320, "Local multiplayer",5, 1, 255, 255, 255]
    args.outputs.labels << [640, 280, "Vs AI", 5, 1, 255, 255, 255]
    args.outputs.labels << [640, 240, "Online multiplayer", 5, 1, 255, 255, 255]
    args.outputs.labels << [480, check_positions_y[args.state.menu_item_selected], "✔️", 5, 0, 255, 255, 255]
    check_ticks = ["local", "ai", "online"]
    if args.inputs.keyboard.key_down.up && args.state.menu_item_selected > 0
        args.state.menu_item_selected -= 1
    end
    if args.inputs.keyboard.key_down.down && args.state.menu_item_selected < 2
        args.state.menu_item_selected += 1
    end
    if args.inputs.keyboard.key_down.enter
        args.state.scene = check_ticks[args.state.menu_item_selected]
    end  
end