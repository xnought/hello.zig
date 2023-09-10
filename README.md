# hello.zig

Matrix multiply in zig [`here`](hello.zig).

**Example**

```zig
const Matrix = matrix(f16); // comptime type

pub fn main() !void {
    // as if I had a batch of 64 with 1000 input neurons and 1000 output neurons
    var a: Matrix = try Matrix.randu([2]usize{ 64, 1000 });
    var b: Matrix = try Matrix.randu([2]usize{ 1000, 1000 });
    defer a.free();
    defer b.free();

    var c = try a.a_matmul(b);
    defer c.free();
}
```
