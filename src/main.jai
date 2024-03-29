/*
# Raylib module test
*/

#import "Basic";
#import "Random";

#import "raylib";

// Constants:
WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;

MIN_FRAME_SPEED :: 1;
MAX_FRAME_SPEED :: 16;

COL_BLACK     :: Color.{ 0, 0, 0, 255 };
COL_WHITE     :: Color.{ 255, 255, 255, 255 };
COL_GREEN     :: Color.{ 0, 255, 0, 255 };
COL_GRAY      :: Color.{ 64, 64, 64, 255 };


main :: () {
  // Prepare the window:
  InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, PROJECT_NAME);
  SetWindowState(cast(u32)ConfigFlags.VSYNC_HINT);
  SetTargetFPS(60);

  defer CloseWindow();

  icon := LoadImage("assets/icon.png");
  SetWindowIcon(icon);


  // Load the texture and prepare the texture rect:
  scarfy_frames :: 6;
  scarfy        := LoadTexture("assets/scarfy.png");
  scarfy_rect   := Rectangle.{ 0.0, 0.0, cast(float)scarfy.width/scarfy_frames, cast(float)scarfy.height };

  // Load the background:
  background := LoadTexture("assets/cyberpunk_street_background.png");
  midground  := LoadTexture("assets/cyberpunk_street_midground.png");
  foreground := LoadTexture("assets/cyberpunk_street_foreground.png");

  // Frame state:
  current_frame := 0;
  frame_counter := 0;
  frame_speed   := 8;
  tick          := 200;
  back_scroll   := 0.0;
  mid_scroll    := 0.0;
  for_scroll    := 0.0;
  exit          := false;

  // Main loop:
  while !exit {
    // Exit on ESC:
    if WindowShouldClose() || IsKeyPressed(cast(s32)KeyboardKey.ESCAPE) {
      exit = true;
    }

    defer frame_counter += 1;

    // Update the current frame:
    if frame_counter >= (60/frame_speed) {
      frame_counter = 0;

      current_frame += 1;
      if current_frame >= scarfy_frames {
        current_frame = 0;
      }

      scarfy_rect.x = cast(float)current_frame * cast(float)scarfy.width/scarfy_frames;
    }

    // Adjust the frame speed:
    if IsKeyPressed(cast(s32)KeyboardKey.RIGHT) {
      frame_speed += 1;
    } else if IsKeyPressed(cast(s32)KeyboardKey.LEFT) {
      frame_speed -= 1;
    }

    if frame_speed > MAX_FRAME_SPEED {
      frame_speed = MAX_FRAME_SPEED;
    } else if frame_speed < MIN_FRAME_SPEED {
      frame_speed = MIN_FRAME_SPEED;
    }

    // Update the background scroll:
    back_scroll -= 0.1 * frame_speed;
    mid_scroll  -= 0.3 * frame_speed;
    for_scroll  -= 0.6 * frame_speed;

    if back_scroll <= -background.width*2.0 {
      back_scroll = 0.0;
    }

    if mid_scroll <= -midground.width*2.0 {
      mid_scroll = 0.0;
    }

    if for_scroll <= -foreground.width*2.0 {
      for_scroll = 0.0;
    }

    // Draw:
    {
      BeginDrawing();
      defer {
        ClearBackground(COL_BLACK);
        EndDrawing();
      }

      // Draw the scene:
      DrawTextureEx(background, .{ back_scroll, 0.0 }, 0.0, 2.0, COL_WHITE) ;
      DrawTextureEx(background, .{ background.width*2.0 + back_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);
      DrawTextureEx(background, .{ background.width*3.0 + back_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);

      DrawTextureEx(midground, .{ mid_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);
      DrawTextureEx(midground, .{ midground.width*2.0 + mid_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);
      DrawTextureEx(midground, .{ midground.width*3.0 + mid_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);

      DrawTextureEx(foreground, .{ for_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);
      DrawTextureEx(foreground, .{ foreground.width*2.0 + for_scroll, 0.0 }, 0.0, 2.0, COL_WHITE);

      // Draw the "scarfy" sprite:
      DrawTextureRec(
        scarfy,
        scarfy_rect,
        Vector2.{ WINDOW_WIDTH/2.0 - scarfy_rect.width/2, cast(float)background.height + 50 },
        COL_WHITE
      );

      // Info pannel:
      DrawRectangleLines(5, foreground.height*2+5, WINDOW_WIDTH-10, WINDOW_HEIGHT-10-foreground.height*2, COL_GRAY);

      start_x := WINDOW_WIDTH/2 - scarfy.width/2;
      start_y := foreground.height*2 + 60;

      // Scarfy texture:
      DrawRectangle(start_x, start_y, scarfy.width+10, scarfy.height+10, COL_GRAY);
      DrawRectangleLines(start_x, start_y, scarfy.width+10, scarfy.height+10, COL_WHITE);

      DrawTexture(scarfy, start_x+5, start_y+5, COL_WHITE);
      DrawRectangleLines(
        start_x+5 + cast(s32)scarfy_rect.x,
        start_y+5 + cast(s32)scarfy_rect.y,
        cast(s32)scarfy_rect.width,
        cast(s32)scarfy_rect.height,
        COL_GREEN
      );

      // Frame speed indicator:
      start_y   += scarfy.height+20;
      box_width := scarfy.width/MAX_FRAME_SPEED;

      for 0..MAX_FRAME_SPEED-1 {
        if it < frame_speed {
          DrawRectangle(start_x + box_width*cast(s32)it+5, start_y, box_width-1, 15, COL_WHITE);
        }
      }

      start_y += 25;
      DrawText("Use LEFT and RIGHT arrow key to increase ANIMATION SPEED.", start_x+5, start_y, 20, COL_WHITE);

      start_y += 25;
      DrawFPS(start_x+5, start_y);
    }
  }
}

#scope_file
