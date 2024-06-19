const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const c = @import("c-bindings.zig");
const Engine = c.Engine;
const Store = c.Store;
const Context = c.Context;
const Module = c.Module;
const Instance = c.Instance;

const f = @cImport({
    @cInclude("foo.h");
});

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    //--------------------------- WASM : P A R T ------------------------------
    const engine = try Engine.init();
    defer engine.deinit();

    const store = try Store.init(&engine);
    defer store.deinit();

    const context = try Context.init(&store);

    // Compile and instantiate the module
    const module = try Module.init(&engine, "examples/wastime-c-bindings/gcd.wat");
    defer module.deinit();

    const instance = try Instance.init(&context, &module, allocator);
    defer instance.deinit();

    // var gcd: w.wasmtime_extern_t = undefined;
    // try instance.get_export("gcd", &gcd);

    // std.debug.print("gcd        : {any}\n", .{gcd});
    // std.debug.print("gcd.of.func: {any}\n", .{gcd.of.func});

    // // We should be able to call it now...
    // const a: i32 = 6;
    // const b: i32 = 27;

    // const param0 = w.wasmtime_val_t{
    //     .kind = w.WASMTIME_I32,
    //     .of = .{ .i32 = a },
    // };

    // const param1 = w.wasmtime_val_t{
    //     .kind = w.WASMTIME_I32,
    //     .of = .{ .i32 = b },
    // };

    // const params = [_]w.wasmtime_val_t{ param0, param1 };
    // const result: w.wasmtime_val_t = undefined;
    // const result_ptr: [*c]w.wasmtime_val_t = @constCast(&result);

    // const context_opt: ?*w.wasmtime_context_t = context.context;
    // std.debug.print("Trying to call gcd function...", .{});
    // // wasmtime_func_call(
    // //  store: ?*wasmtime_context_t,
    // //  func: [*c]const wasmtime_func_t,
    // //  args: [*c]const wasmtime_val_t,
    // //  nargs: usize,
    // //  results: [*c]wasmtime_val_t,
    // //  nresults: usize,
    // //  trap: [*c]?*wasm_trap_t) ?*wasmtime_error_t;
    // const err = w.wasmtime_func_call(
    //     context_opt,
    //     &gcd.of.func,
    //     &params[0],
    //     2,
    //     result_ptr,
    //     1,
    //     null,
    // );

    // if (err != null) {
    //     std.debug.print("failed to call gcd", .{});
    // } else {
    //     std.debug.print("gcd({d}, {d}) = {d}\n", .{ a, b, result.of.i32 });
    // }

    //--------------------------- R A Y L I B : P A R T -----------------------
    // Now let's play with Raylib
    r.InitWindow(800, 600, "Raylib in Zig");
    defer r.CloseWindow();

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.RAYWHITE);
        r.DrawText(
            "All your codebase are belong to us.",
            190,
            200,
            20,
            r.LIGHTGRAY,
        );
    }

    const answer = f.foo(30, 12);
    std.debug.print("{d} is the answer to the Ultimate Question of Life, the Universe, and Everything\n", .{answer});
}
