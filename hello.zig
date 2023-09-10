const std = @import("std");
const print = std.debug.print;

fn matrix(comptime t: type) type {
    return struct {
        shape: [2]usize,
        data: [*]t,
        pub fn init(data: [*]t, shape: [2]usize) @This() {
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
    };
}

const MatrixU8 = matrix(u8);

const Matrix = struct {
    shape: [2]usize,
    data: [*]f16,
    pub fn init(data: [*]f16, shape: [2]usize) Matrix {
        return Matrix{ .data = data, .shape = shape };
    }
    pub fn print(self: Matrix) void {
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
    fn index(self: Matrix, i: usize, j: usize) usize {
        return i * self.shape[1] + j;
    }
    fn value(self: Matrix, row: usize, col: usize) f16 {
        return self.data[self.index(row, col)]; // self.data[i][j]
    }
    fn set_value(self: Matrix, row: usize, col: usize, new_value: f16) void {
        self.data[self.index(row, col)] = new_value; // self.data[i][j] = value
    }
    pub fn matmul(self: Matrix, other: Matrix, out: Matrix) void {
        var m: usize = self.shape[0];
        var inner: usize = self.shape[1];
        var n: usize = other.shape[1];

        var i: usize = 0;
        while (i < m) : (i += 1) {
            var j: usize = 0;
            while (j < n) : (j += 1) {
                var k: usize = 0;
                var summed: f16 = 0.0;
                while (k < inner) : (k += 1) {
                    summed += self.value(i, k) * other.value(k, j);
                }
                out.set_value(i, j, summed);
            }
        }
    }
};

pub fn main() void {
    var d: [4]u8 = .{ 1, 2, 3, 4 };
    var out: [4]u8 = .{ 0, 0, 0, 0 };
    var s = [2]usize{ 2, 2 };
    var a = MatrixU8.init(&d, s);
    var c = MatrixU8.init(&out, s);
    a.matmul(a, c);
    c.print();
}
