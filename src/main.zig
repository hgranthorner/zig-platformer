const c = @cImport({
    @cInclude("SDL.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;

const x = 800;
const y = 600;
const FPS = 60;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", 
        c.SDL_WINDOWPOS_UNDEFINED, 
        c.SDL_WINDOWPOS_UNDEFINED, 
        x, 
        y, 
        c.SDL_WINDOW_OPENGL
        ) orelse
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

    var rect = c.SDL_Rect{.x = 10, .y = 10, .w = 30, .h = 30 };

    var quit = false;
    const render_timer = @floatToInt(u32, 1000 / FPS);

    while (!quit) {
        const start_frame_time = c.SDL_GetTicks();
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    const e = event.key;
                    switch (e.keysym.sym) {
                        c.SDLK_RIGHT => {
                            var x_ptr = &rect.x;
                            x_ptr.* = rect.x + 10;
                        },
                        else => {},
                    }
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
        const ms_elapsed: i64 = @maximum(10, @as(i64, render_timer) - @as(i64, end_frame_time - start_frame_time));
        c.SDL_Delay(@intCast(u32, ms_elapsed));
    }
}