const std = @import("std");
const zixelwolf = @import("zixelwolf");

const zlua = @import("zlua");

const Lua = zlua.Lua;

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;

pub var last_time: u64 = 0;
pub var current_time: u64 = 0;
pub var elapsed_time: f32 = 0;

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Pong", "0.0.0", "sdl-examples.pong");
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);

    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = create_window_and_renderer: {
        var window: ?*c.SDL_Window = null;
        var renderer: ?*c.SDL_Renderer = null;
        _ = c.SDL_CreateWindowAndRenderer("Pong", WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer);
        errdefer comptime unreachable;

        break :create_window_and_renderer .{ window.?, renderer.? };
    };

    return .{ window, renderer };
}

fn render(renderer: ?*c.SDL_Renderer) !void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, c.SDL_ALPHA_OPAQUE);
    _ = c.SDL_RenderClear(renderer);

    // try game.draw(renderer);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn handleEvent(event: c.SDL_Event) !void {
    switch (event.type) {
        c.SDL_EVENT_QUIT => {
            return error.Quit;
        },
        c.SDL_EVENT_KEY_DOWN, c.SDL_EVENT_KEY_UP => {
            // const down = event.type == c.SDL_EVENT_KEY_DOWN;
            switch (event.key.scancode) {
                // c.SDL_SCANCODE_W => controller_state.key_w = down,
                else => {},
            }
        },
        else => {},
    }
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    last_time = c.SDL_GetTicks();

    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Initialize the Lua vm
    var lua = try Lua.init(allocator);
    defer lua.deinit();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            handleEvent(event) catch |err| {
                if (err == error.Quit) break :main_loop;
            };
        }

        {
            current_time = c.SDL_GetTicks();
            elapsed_time = @as(f32, @floatFromInt(current_time - last_time)) / 1000;
            // game.update();
            last_time = c.SDL_GetTicks();
        }

        try render(renderer);
    }
    // Add an integer to the Lua stack and retrieve it
    lua.pushInteger(42);
    std.debug.print("Lua: {}\n", .{try lua.toInteger(1)});
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try zixelwolf.bufferedPrint();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
