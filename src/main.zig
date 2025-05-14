const std = @import("std");
const args = @import("args");
const stb = @import("zstbi");
const rand = std.Random;

const RgbColor = struct {
    red: u64,
    green: u64,
    blue: u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const Options = struct {
        file: ?[]const u8 = null,
        rgb: bool = false,
        time: bool = false,
        help: bool = false,
        method: []const u8 = "average", // "average" or "kmeans"
        count: u32 = 5, // for kmeans
        pub const shorthands = .{
            .f = "file",
            .r = "rgb",
            .t = "time",
            .h = "help",
            .m = "method",
            .c = "count",
        };
    };

    const opt = args.parseForCurrentProcess(Options, allocator, .silent) catch return;
    defer opt.deinit();

    if (opt.options.help) {
        std.debug.print(
            \\chromasampler: extract colors from an image
            \\Usage: chromasampler -f <file> [OPTIONS]
            \\Options:
            \\  -f, --file     Path to image file
            \\  -m, --method   "average" (default) or "kmeans"
            \\  -c, --count    Number of colors for kmeans (default 5)
            \\  -r             Output in rgb(r,g,b) form
            \\  -t             Print processing time
            \\  -h, --help     Show this help
        , .{});
        return;
    }

    const file_path = opt.options.file orelse {
        std.log.err("No image file provided. Use -f to specify.\n", .{});
        std.process.exit(1);
    };

    var timer: ?std.time.Timer = null;
    if (opt.options.time) {
        timer = try std.time.Timer.start();
    }

    const image = try loadImage(file_path);
    defer stb.Image.deinit(&image);

    if (std.mem.eql(u8, opt.options.method, "average")) {
        const avg = calculateAverageRgb(&image);
        printColor(avg, opt.options.rgb);
    } else if (std.mem.eql(u8, opt.options.method, "kmeans")) {
        const palette = try calculateKMeansPalette(allocator, &image, opt.options.count);
        defer allocator.free(palette);

        if (palette.len == 1) {
            printColor(palette[0], opt.options.rgb);
        } else {
            for (palette, 0..) |c, i| {
                std.debug.print("Color {d}: ", .{i});
                printColor(c, opt.options.rgb);
            }
        }
    } else {
        std.log.err("Unknown method: {}\n", .{opt.options.method});
        std.process.exit(1);
    }

    if (timer) |t| {
        const elapsed = t.read();
        std.log.info("Time: {d}ms", .{elapsed / 1_000_000});
    }
}

fn loadImage(path: []const u8) !stb.Image {
    const alloc = std.heap.page_allocator;

    var zb = try alloc.alloc(u8, path.len + 1);
    defer alloc.free(zb);
    std.mem.copyForwards(u8, zb[0..path.len], path);
    zb[path.len] = 0;

    stb.init(alloc);
    const a: [:0]const u8 = zb[0..path.len :0];
    const img = try stb.Image.loadFromFile(a, 0);
    return img;
}

fn printColor(c: RgbColor, rgbOut: bool) void {
    if (rgbOut) {
        std.debug.print("rgb({d},{d},{d})\n", .{ c.red, c.green, c.blue });
    } else {
        const r = @as(u8, @intCast(c.red));
        const g = @as(u8, @intCast(c.green));
        const b = @as(u8, @intCast(c.blue));
        std.debug.print("#{X:0>2}{X:0>2}{X:0>2}\n", .{ r, g, b });
    }
}

fn calculateAverageRgb(image: *const stb.Image) RgbColor {
    const w = image.width;
    const h = image.height;
    const components: usize = @intCast(image.num_components);
    const total = @as(u64, w) * @as(u64, h);

    var sum = RgbColor{ .red = 0, .green = 0, .blue = 0 }; // Fixed initialization
    const data = image.data;

    for (0..total) |i| {
        const idx = i * components;
        sum.red += data[idx + 0];
        sum.green += data[idx + 1];
        sum.blue += data[idx + 2];
    }

    sum.red /= total;
    sum.green /= total;
    sum.blue /= total;
    return sum;
}

fn calculateKMeansPalette(
    allocator: std.mem.Allocator,
    image: *const stb.Image,
    k: u32,
) ![]RgbColor {
    const w = image.width;
    const h = image.height;
    const total = @as(usize, w * h);
    const comps: usize = @intCast(image.num_components);

    var pixels = try allocator.alloc([3]f64, total);
    defer allocator.free(pixels);

    for (0..total) |i| {
        const base = i * comps;
        pixels[i][0] = @floatFromInt(image.data[base + 0]);
        pixels[i][1] = @floatFromInt(image.data[base + 1]);
        pixels[i][2] = @floatFromInt(image.data[base + 2]);
    }

    // initialize centroids by picking k random pixels
    var rng = rand.DefaultPrng.init(0);
    var centroids = try allocator.alloc([3]f64, k);
    for (k) |ci| {
        const total_value: u64 = @intCast(total);
        const pick = rng.random() % total_value;
        const a: usize = @intCast(pick);
        centroids[ci] = pixels[a];
    }

    var labels = try allocator.alloc(u32, total);
    defer allocator.free(labels);

    // lloyd iterations
    const maxIters = 50;
    for (maxIters) |_| {
        // assignment
        for (total) |i| {
            var best = 0;
            var bestDist = distanceSquared(pixels[i], centroids[0]);
            for (1..k) |ci| {
                const d = distanceSquared(pixels[i], centroids[ci]);
                if (d < bestDist) {
                    bestDist = d;
                    best = ci;
                }
            }
            labels[i] = best;
        }
        // update
        var counts = try allocator.alloc(u64, k);
        defer allocator.free(counts);
        var sums = try allocator.alloc([3]f64, k);
        defer allocator.free(sums);

        // zero
        for (k) |ci| {
            counts[ci] = 0;
            sums[ci] = [_]f64{ 0, 0, 0 };
        }
        // accumulate
        for (total) |i| {
            const ci = labels[i];
            counts[ci] += 1;
            sums[ci][0] += pixels[i][0];
            sums[ci][1] += pixels[i][1];
            sums[ci][2] += pixels[i][2];
        }
        // recompute and check for empties
        var changed = false;
        for (k) |ci| {
            if (counts[ci] > 0) {
                const a: f64 = @intCast(counts[ci]);
                const inv = 1.0 / a;
                const newC = [_]f64{
                    sums[ci][0] * inv,
                    sums[ci][1] * inv,
                    sums[ci][2] * inv,
                };
                if (distanceSquared(newC, centroids[ci]) > 1e-4) {
                    changed = true;
                }
                centroids[ci] = newC;
            }
        }
        if (!changed) break;
    }

    var out = try allocator.alloc(RgbColor, k);
    for (k) |ci| {
        out[ci] = .{
            .red = @as(u64, std.math.round(centroids[ci][0])),
            .green = @as(u64, std.math.round(centroids[ci][1])),
            .blue = @as(u64, std.math.round(centroids[ci][2])),
        };
    }
    return out;
}

fn distanceSquared(a: [3]f64, b: [3]f64) f64 {
    const dx = a[0] - b[0];
    const dy = a[1] - b[1];
    const dz = a[2] - b[2];
    return dx * dx + dy * dy + dz * dz;
}
