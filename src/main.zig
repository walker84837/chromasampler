const std = @import("std");
const argsParser = @import("args");
const c = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", "1");
    @cInclude("stb/stb_image.h");
});

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

    const timer = if (options.options.time) try std.time.Timer.start() else null;
    const avg_color = try calculateAverageRgb(file);
    const elapsed = if (timer) |t| t.read() else 0;

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

fn calculateAverageRgb(path: []const u8) !RgbColor {
    var width: c_int = 0;
    var height: c_int = 0;
    var channels: c_int = 0;

    const image = c.stbi_load(path.ptr, &width, &height, &channels, 0);
    defer if (image != null) c.stbi_image_free(image);

    if (image == null) {
        std.log.err("Failed to load image: {s}", .{path});
        return error.ImageLoadFailed;
    }

    const total_pixels = @as(u64, @intCast(width)) * @as(u64, @intCast(height));
    var rgb = RgbColor{ .red = 0, .green = 0, .blue = 0 };

    const actual_channels = @as(usize, @intCast(channels));
    const image_ptr: [*]const u8 = @ptrCast(image);

    for (0..total_pixels) |i| {
        const idx = i * actual_channels;
        rgb.red += image_ptr[idx];
        rgb.green += image_ptr[idx + 1];
        rgb.blue += image_ptr[idx + 2];
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
