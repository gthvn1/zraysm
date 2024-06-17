const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const w = @cImport({
    @cInclude("wasi.h");
    @cInclude("wasm.h");
    @cInclude("wasmtime.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

const ZaylibError = error{
    EngineFailed,
    StoreFailed,
    CompileFailed,
    InstanceFailed,
};

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    // Start by trying to load a WASM file and export a function
    const engine = w.wasm_engine_new();
    if (engine == null) {
        return ZaylibError.EngineFailed;
    }
    defer w.wasm_engine_delete(engine);

    const store = w.wasm_store_new(engine);
    if (store == null) {
        return ZaylibError.StoreFailed;
    }
    defer w.wasm_store_delete(store);

    // Load the binary Wasm file
    const file = try std.fs.cwd().openFile("wasm/add.wasm", .{});
    defer file.close();

    const fstat = try file.stat();
    const fsize = fstat.size;
    std.debug.print("File size = {d}\n", .{fsize});

    const binary: []u8 = try allocator.alloc(u8, fsize);
    defer allocator.free(binary);

    const bytes_read = try file.readAll(binary);
    std.debug.print("Bytes read = {d}\n", .{bytes_read});
    std.debug.print("binary = {}\n", .{std.fmt.fmtSliceHexLower(binary)});

    var binary_vec: w.wasm_byte_vec_t = .{
        .size = fsize,
        .data = binary.ptr,
    };

    const module = w.wasm_module_new(store, &binary_vec);
    if (module == null) {
        return ZaylibError.CompileFailed;
    }
    defer w.wasm_module_delete(module);

    const imports: w.wasm_extern_vec_t = .{
        .size = 0,
        .data = null,
    };

    const instance = w.wasm_instance_new(store, module, &imports, null);
    if (instance == null) {
        return ZaylibError.InstanceFailed;
    }
    defer w.wasm_instance_delete(instance);

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
