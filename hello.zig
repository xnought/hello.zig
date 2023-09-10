const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;
var rand = std.rand.DefaultPrng.init(42);

fn matrix(comptime t: type) type {
    return struct {
        shape: [2]usize,
        data: []t,
        pub fn init(data: []t, shape: [2]usize) @This() {
            return @This(){ .data = data, .shape = shape };
        }
        pub fn print(self: @This()) void {
            var m: usize = self.shape[0];
            var n: usize = self.shape[1];
            var i: usize = 0;
            while (i < m) : (i += 1) {
                var j: usize = 0;
                std.debug.print("| ", .{});
                while (j < n) : (j += 1) {
                    std.debug.print("{} ", .{self.value(i, j)});
                }
                std.debug.print("|\n", .{});
            }
        }
        fn index(self: @This(), i: usize, j: usize) usize {
            return i * self.shape[1] + j;
        }
        fn value(self: @This(), row: usize, col: usize) t {
            return self.data[self.index(row, col)]; // self.data[i][j]
        }
        fn set_value(self: @This(), row: usize, col: usize, new_value: t) void {
            self.data[self.index(row, col)] = new_value; // self.data[i][j] = value
        }
        pub fn matmul(self: @This(), other: @This(), out: @This()) void {
            var m: usize = self.shape[0];
            var inner: usize = self.shape[1];
            var n: usize = other.shape[1];

            var i: usize = 0;
            while (i < m) : (i += 1) {
                var j: usize = 0;
                while (j < n) : (j += 1) {
                    var k: usize = 0;
                    var summed: t = 0.0;
                    while (k < inner) : (k += 1) {
                        summed += self.value(i, k) * other.value(k, j);
                    }
                    out.set_value(i, j, summed);
                }
            }
        }

        pub fn alloc(shape: [2]usize) !@This() {
            var d: []t = try allocator.alloc(t, shape[0] * shape[1]);
            var m: @This() = @This().init(d, shape);
            return m;
        }
        pub fn free(self: @This()) void {
            allocator.free(self.data);
        }
        pub fn a_matmul(self: @This(), other: @This()) !@This() {
            var out: @This() = try @This().alloc([2]usize{ self.shape[0], other.shape[1] });
            self.matmul(other, out);
            return out;
        }
        pub fn randu(shape: [2]usize) !@This() {
            var m: @This() = try @This().alloc(shape);
            var i: usize = 0;
            while (i < shape[0] * shape[1]) : (i += 1) {
                m.data[i] = @floatCast(t, rand.random().float(f32));
            }
            return m;
        }
    };
}

const Matrix = matrix(f16);

pub fn main() !void {
    // as if I had a batch of 64 with 1000 input neurons and 1000 output neurons
    var a: Matrix = try Matrix.randu([2]usize{ 64, 1000 });
    var b: Matrix = try Matrix.randu([2]usize{ 1000, 1000 });
    defer a.free();
    defer b.free();

    const start = std.time.milliTimestamp();
    var c = try a.a_matmul(b);
    defer c.free();
    const end = std.time.milliTimestamp();

    print("time: {}\n", .{end - start});
}
