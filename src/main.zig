const c = @cImport({
    @cInclude("SDL.h");
});
const print = @import("std").debug.print;
const assert = @import("std").debug.assert;

const screen_width = 800;
const screen_height = 600;
const fps = 60;

const Entity = struct {
    rect: c.SDL_Rect,
    y_velocity: i32,
    x_velocity: i32,
    color: [4]u8,
};

const Player = struct {
    rect: c.SDL_Rect,
    y_velocity: i32,
    x_velocity: i32,
    color: [4]u8,
};

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

    var player = Player{ .rect = c.SDL_Rect{ .x = 10, .y = 10, .w = 30, .h = 30 }, .y_velocity = 0, .x_velocity = 0, .color = .{ 0, 255, 0, 255 } };
    var player_rect = &player.rect;

    var quit = false;
    const render_timer = @floatToInt(i64, 1000 / fps);
    var state = c.SDL_GetKeyboardState(null);

    while (!quit) {
        const start_frame_time = c.SDL_GetTicks();

        _ = c.SDL_PumpEvents();

        applyPlayerControls(player_rect, state);

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    switch(event.key.keysym.scancode) {
                        c.SDL_SCANCODE_SPACE => {
                            print("Pressed space.\n", .{});
                            player.y_velocity = -20;
                            print("{}.\n", .{player.y_velocity});
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        applyGravity(&player);
        applyVelocity(&player);

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, player.color[0], player.color[1], player.color[2], player.color[3]);
        _ = c.SDL_RenderFillRect(renderer, player_rect);

        c.SDL_RenderPresent(renderer);

        const end_frame_time = c.SDL_GetTicks();
        const ms_elapsed: i64 = @maximum(10, render_timer - @as(i64, end_frame_time - start_frame_time));
        c.SDL_Delay(@intCast(u32, ms_elapsed));
    }
}

fn applyGravity(player: *Player) void {
    if (player.rect.y + player.rect.h >= screen_height and player.y_velocity >= 0) {
        player.rect.y = screen_height - player.rect.h;
        player.y_velocity = 0;
        return;
    }

    player.y_velocity += 1;
}

fn applyVelocity(player: *Player) void {
    print("applyVelocity: {} - {}\n", .{player.rect.y, player.y_velocity});
    player.rect.x += player.x_velocity;
    player.rect.y += player.y_velocity;
    print("applyVelocity: {} - {}\n", .{player.rect.y, player.y_velocity});
}

fn applyPlayerControls(rect: *c.SDL_Rect, keyboard_state_array: [*]const u8) void {
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
