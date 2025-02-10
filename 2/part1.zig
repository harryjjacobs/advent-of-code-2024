const std = @import("std");

pub fn checkLine(line: []u8) !bool {
    var iter = std.mem.split(u8, line, " ");
    const first = iter.next().?;
    var prev: i32 = try std.fmt.parseInt(i32, first, 10);
    var direction: i32 = -1;
    while (iter.next()) |str| {
        const curr = try std.fmt.parseInt(i32, str, 10);
        const curr_dir = @intFromBool(curr > prev);
        const diff = @abs(curr - prev);
        prev = curr;
        if (diff < 1 or diff > 3) {
            // invalid adjacent levels
            return false;
        }
        if (direction == -1) { // first iteration
            direction = curr_dir;
            continue;
        } else if (curr_dir != direction) {
            // change in direction
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();

    var count: i32 = 0;
    var buffered_reader = std.io.bufferedReader(file.reader());
    var stream = buffered_reader.reader();
    while (try stream.readUntilDelimiterOrEofAlloc(arena.allocator(), '\n', 8 * 1000)) |line| {
        count += @intFromBool(try checkLine(line));
    }

    std.debug.print("{d}", .{count});
}
