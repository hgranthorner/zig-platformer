const c = @cImport({
    @cInclude("SDL.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;

const screen_width = 800;
const screen_height = 600;
const fps = 60;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, screen_width, screen_height, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var rect = c.SDL_Rect{ .x = 10, .y = 10, .w = 30, .h = 30 };

    var quit = false;
    const render_timer = @floatToInt(i64, 1000 / fps);
    var state = c.SDL_GetKeyboardState(null);

    while (!quit) {
        const start_frame_time = c.SDL_GetTicks();

        _ = c.SDL_PumpEvents();

        try_move_player(&rect, state);

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 100, 0, 0, 255);
        _ = c.SDL_RenderFillRect(renderer, &rect);

        c.SDL_RenderPresent(renderer);

        const end_frame_time = c.SDL_GetTicks();
        const ms_elapsed: i64 = @maximum(10, render_timer - @as(i64, end_frame_time - start_frame_time));
        c.SDL_Delay(@intCast(u32, ms_elapsed));
    }
}

fn try_move_player(rect: *c.SDL_Rect, keyboard_state_array: [*]const u8) void {
    if (keyboard_state_array[c.SDL_SCANCODE_RIGHT] == 1) {
        rect.x += 10;
    }

    if (keyboard_state_array[c.SDL_SCANCODE_LEFT] == 1) {
        rect.x -= 10;
    }

    if (keyboard_state_array[c.SDL_SCANCODE_DOWN] == 1) {
        rect.y += 10;
    }

    if (keyboard_state_array[c.SDL_SCANCODE_UP] == 1) {
        rect.y -= 10;
    }

    if (rect.x < 0) {
        rect.x = 0;
    }

    if (rect.x + rect.w > screen_width) {
        rect.x = screen_width - rect.w;
    }

    if (rect.y < 0) {
        rect.y = 0;
    }

    if (rect.y + rect.h > screen_height) {
        rect.y = screen_height - rect.h;
    }
}
