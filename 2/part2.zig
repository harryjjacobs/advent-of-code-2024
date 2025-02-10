const std = @import("std");

pub fn isSafe(a: i32, b: i32, direction: *i32) bool {
    const curr_dir = @intFromBool(a > b);
    const diff = @abs(a - b);
    if (diff < 1 or diff > 3) {
        // invalid adjacent levels
        return false;
    }
    if (direction.* == -1) { // first iteration
        direction.* = curr_dir;
        return true;
    } else if (curr_dir != direction.*) {
        // change in direction
        return false;
    }
    return true;
}

pub fn isLineSafe(arr: std.ArrayList(i32), removeLevel: usize) bool {
    const start: usize = if (removeLevel == 0) 2 else 1;
    var prev = arr.items[start - 1];
    var direction: i32 = -1;
    for (start..arr.items.len) |i| {
        if (i == removeLevel) {
            continue;
        }
        if (!isSafe(prev, arr.items[i], &direction)) {
            return false;
        }
        prev = arr.items[i];
    }
    return true;
}

pub fn checkLineSafety(allocator: std.mem.Allocator, line: []u8) !bool {
    var arr = std.ArrayList(i32).init(allocator);
    var iter = std.mem.split(u8, line, " ");
    while (iter.next()) |str| {
        const val = try std.fmt.parseInt(i32, str, 10);
        try arr.append(val);
    }

    var direction: i32 = -1;
    var allSafe = true;
    for (1..arr.items.len) |i| {
        if (!isSafe(arr.items[i - 1], arr.items[i], &direction)) {
            allSafe = false;
        }
    }

    if (allSafe) {
        return true;
    }

    for (0..arr.items.len) |remove| {
        if (isLineSafe(arr, remove)) {
            return true;
        }
    }

    return false;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();

    var count: i64 = 0;
    var buffered_reader = std.io.bufferedReader(file.reader());
    var stream = buffered_reader.reader();
    while (try stream.readUntilDelimiterOrEofAlloc(arena.allocator(), '\n', 8 * 1000)) |line| {
        count += @intFromBool(try checkLineSafety(arena.allocator(), line));
    }

    std.debug.print("{d}", .{count});
}
