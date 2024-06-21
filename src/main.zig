const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

const w = @cImport({
    @cInclude("wasmer.h");
});

pub const WasmError = error{
    OpenWat,
    ReadWat,
    WatSize,
    EngineNew,
    StoreNew,
    ModuleNew,
    InstanceNew,
    Exports,
    FuncNull,
    FuncCall,
};

pub fn main() !void {
    // ----------------------- W A S M E R ------------------------------------
    const wat_filename = "examples/wastime-c-bindings/gcd.wat";
    //std.debug.print("Read {s}...\n", .{wat_filename});
    const wat_file = std.fs.cwd().openFile(wat_filename, .{}) catch return WasmError.OpenWat;
    defer wat_file.close();

    // Get its size
    const fstat = try wat_file.stat();

    // Allocate memory for the string
    const allocator = std.heap.c_allocator;
    const wat_string: []u8 = try allocator.alloc(u8, fstat.size);
    defer allocator.free(wat_string);

    const bytes_read = wat_file.readAll(wat_string) catch return WasmError.ReadWat;
    if (bytes_read != fstat.size) {
        return WasmError.WatSize;
    }

    var wat = w.wasm_byte_vec_t{
        .size = wat_string.len,
        .data = @as([*c]u8, @constCast(wat_string.ptr)),
    };
    std.debug.print("wat: {any}\n", .{wat});

    // Compile
    var wasm_bytes = w.wasm_byte_vec_t{
        .size = 0,
        .data = null,
    };
    w.wat2wasm(&wat, &wasm_bytes);
    defer w.wasm_byte_vec_delete(&wasm_bytes);
    std.debug.print("wasm: {any}\n", .{wasm_bytes});

    std.debug.print("Creating the store...\n", .{});
    const engine = w.wasm_engine_new() orelse return WasmError.EngineNew;
    defer w.wasm_engine_delete(engine);

    const store = w.wasm_store_new(engine) orelse return WasmError.StoreNew;
    defer w.wasm_store_delete(store);

    std.debug.print("Compiling module...\n", .{});
    const module = w.wasm_module_new(store, &wasm_bytes) orelse return WasmError.ModuleNew;
    defer w.wasm_module_delete(module);

    std.debug.print("Instantiating module...\n", .{});
    const import_object = w.wasm_extern_vec_t{ .size = 0, .data = null };

    const instance = w.wasm_instance_new(@as(?*w.wasm_store_t, store), @as(?*w.wasm_module_t, module), &import_object, null) orelse return WasmError.InstanceNew;
    const instance_opt: ?*w.wasm_instance_t = instance;
    defer w.wasm_instance_delete(instance_opt);

    std.debug.print("Retrieving exports...\n", .{});
    var exports = w.wasm_extern_vec_t{ .size = 0, .data = null };
    const exports_ptr = @as([*c]w.wasm_extern_vec_t, @ptrCast(&exports));
    w.wasm_instance_exports(instance_opt, exports_ptr);
    if (exports.size == 0) {
        return WasmError.Exports;
    }
    defer w.wasm_extern_vec_delete(&exports);

    std.debug.print("Retrieving the gcd function...\n", .{});
    const gcd_func = w.wasm_extern_as_func(exports.data[0]);

    if (gcd_func == null) {
        return WasmError.FuncNull;
    }

    std.debug.print("Calling gcd function...\n", .{});
    const args_val = [2]w.wasm_val_t{
        w.wasm_val_t{ .kind = w.WASM_I32, .of = .{ .i32 = 54 } },
        w.wasm_val_t{ .kind = w.WASM_I32, .of = .{ .i32 = 66 } },
    };
    const args_data = @as([*c]w.wasm_val_t, @constCast(&args_val[0]));
    const args = w.wasm_val_vec_t{ .size = 2, .data = args_data };

    var results_val = [1]w.wasm_val_t{w.wasm_val_t{ .kind = w.WASM_I32, .of = .{ .i32 = 0 } }};
    const results_data = @as([*c]w.wasm_val_t, @ptrCast(&results_val[0]));
    var results = w.wasm_val_vec_t{ .size = 1, .data = results_data };

    const trap = w.wasm_func_call(gcd_func, &args, &results);
    if (trap != null) {
        return WasmError.FuncCall;
    }

    std.debug.print("Results of sum {d} {d} -> {any}\n", .{
        args_val[0].of.i32,
        args_val[1].of.i32,
        results.data[0].of.i32,
    });

    // ----------------------- R A Y L I B ------------------------------------
    r.InitWindow(800, 600, "Raylib in Zig");
    while (!r.WindowShouldClose()) {
        // Start drawing
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawText(
            "All your codebase are belong to us.",
            190,
            200,
            20,
            r.LIGHTGRAY,
        );
        r.EndDrawing();
    }

    r.CloseWindow();

    const answer = f.foo(30, 12);
    std.debug.print("{d} is the answer to the Ultimate Question of Life, the Universe, and Everything", .{answer});
}
