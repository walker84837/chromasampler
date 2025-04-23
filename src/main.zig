const std = @import("std");
const argsParser = @import("args");
const stb = @import("zstbi");

const RgbColor = struct {
    red: u64,
    green: u64,
    blue: u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const options = argsParser.parseForCurrentProcess(struct {
        file: ?[]const u8 = null,
        rgb: bool = false,
        time: bool = false,
        help: bool = false,

        pub const shorthands = .{
            .f = "file",
            .r = "rgb",
            .t = "time",
            .h = "help",
        };
    }, allocator, .silent) catch return;
    defer options.deinit();

    if (options.options.help) {
        std.debug.print("chromasampler: Find the average color in an image\n" ++
            "Usage: chromasampler -f FILENAME [OPTIONS]\n" ++
            "Options:\n" ++
            "  -f, --file FILENAME    Path to image file\n" ++
            "  -r                     Output RGB format\n" ++
            "  -t                     Measure processing time\n" ++
            "  -h, --help             Show this help\n", .{});
        return;
    }

    const file = options.options.file orelse {
        std.log.err("No image file provided. Use -f to specify.", .{});
        std.process.exit(1);
    };

    var timer: ?std.time.Timer = null;
    if (options.options.time) {
        timer = try std.time.Timer.start();
    }
    const avg_color = try calculateAverageRgb(file);
    const elapsed = if (timer) |*t| t.read() else 0;

    if (options.options.time) {
        std.log.info("Processing time: {d}ms", .{elapsed / 1_000_000});
    }

    if (options.options.rgb) {
        std.debug.print("rgb({d},{d},{d})\n", .{
            avg_color.red,
            avg_color.green,
            avg_color.blue,
        });
    } else {
        const hex = try rgbToHex(allocator, avg_color);
        defer allocator.free(hex);
        std.debug.print("{s}\n", .{hex});
    }
}

fn toTrailingStringAlloc(allocator: std.mem.Allocator, s: []const u8) ![:0]const u8 {
    var buf = try allocator.alloc(u8, s.len + 1);
    std.mem.copyBackwards(u8, buf[0..s.len], s);
    buf[s.len] = 0;

    const const_buf: []const u8 = buf;
    const trailing: [:0]const u8 = @ptrCast(const_buf);
    return trailing;
}

fn calculateAverageRgb(path: []const u8) !RgbColor {
    const allocator = std.heap.page_allocator;
    const image_path = try toTrailingStringAlloc(allocator, path);
    defer allocator.free(image_path);

    stb.init(allocator);
    defer stb.deinit();

    var image = try stb.Image.loadFromFile(image_path, 0);
    defer stb.Image.deinit(&image);

    const width = image.width;
    const height = image.height;
    const channels = image.num_components;
    const total_pixels = @as(u64, width * height);
    var rgb = RgbColor{ .red = 0, .green = 0, .blue = 0 };

    const actual_channels = @as(usize, @intCast(channels));
    const image_data = image.data;

    for (0..total_pixels) |i| {
        const idx = i * actual_channels;
        rgb.red += image_data[idx];
        rgb.green += image_data[idx + 1];
        rgb.blue += image_data[idx + 2];
    }

    rgb.red /= total_pixels;
    rgb.green /= total_pixels;
    rgb.blue /= total_pixels;

    return rgb;
}

fn rgbToHex(allocator: std.mem.Allocator, color: RgbColor) ![]const u8 {
    const r = @as(u8, @intCast(color.red));
    const g = @as(u8, @intCast(color.green));
    const b = @as(u8, @intCast(color.blue));
    return try std.fmt.allocPrint(allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b });
}
