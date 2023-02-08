
def horizontal_bar(y_position)
    {
      x: 150,
      y: y_position,
      w: 960,
      h: 400,
      path: 'sprites/horizontal-bar.png',
    }
  end
  

def vertical_bar(x_position)
    {
      x: x_position,
      y: 60,
      w: 400,
      h: 600,
      path: 'sprites/vertical-bar.png',
    }
end

def make_board(args)
    args.state.board ||= [
        {
         begin_x: 0,
         end_x: 426,
         begin_y: 480,
         end_y: 720,
       },
       {
         begin_x: 426,
         end_x: 852,
         begin_y: 480,
         end_y: 720,
       },
       {
         begin_x: 852,
         end_x: 1280,
         begin_y: 480,
         end_y: 720,
       },
       {
         begin_x: 0,
         end_x: 426,
         begin_y: 240,
         end_y: 480,
       },
       {
         begin_x: 426,
         end_x: 852,
         begin_y: 240,
         end_y: 480,
       },
       {
         begin_x: 852,
         end_x: 1280,
         begin_y: 240,
         end_y: 480,
       },
       {
         begin_x: 0,
         end_x: 426,
         begin_y: 0,
         end_y: 240,
       },
       {
         begin_x: 426,
         end_x: 852,
         begin_y: 0,
         end_y: 240,
       },
       {
         begin_x: 852,
         end_x: 1280,
         begin_y: 0,
         end_y: 240,
       },
     ]
args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
    }
    args.outputs.sprites << [horizontal_bar(60), 
    horizontal_bar(270), 
    vertical_bar(300), 
    vertical_bar(600)]
end
