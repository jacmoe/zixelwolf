const std = @import("std");
const Lua = @import("lua").Lua;

pub fn main() anyerror!void {
    var lua = try Lua.init(std.testing.allocator);
    defer lua.destroy();

    lua.openLibs();

    _ = lua.run("print ('Hello from Lua!')");

    lua.set("int32", 42);
    var int = lua.get(i32, "int32");
    std.log.info("Int: {}", .{int});

    lua.set("string", "I'm a string");
    const str = lua.get([] const u8, "string");
    std.log.info("String: {s}", .{str});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}

test "lua test" {
    const expectEqual = std.testing.expectEqual;
    var lua = try Lua.init(std.testing.allocator);
    defer lua.destroy();

    lua.openLibs();

    lua.set("int32", 42);
    var int = lua.get(i32, "int32");
    try expectEqual(int, 42);

    // lua.set("string", "I'm a string");
    // const str = lua.get([] const u8, "string");
    // const e_str = "I'm a string";
    // try expectEqual(str, e_str);
}
