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

const WasmError = error{
    EngineInit,
    StoreInit,
    ContextInit,
    ModuleInit,
    ModuleIsNull,
    InstanceInit,
    ParseWat,
};

const Engine = struct {
    engine: *w.wasm_engine_t,

    pub fn init() WasmError!Engine {
        const engine = w.wasm_engine_new();

        return Engine{
            .engine = engine orelse return WasmError.EngineInit,
        };
    }

    pub fn deinit(self: *const Engine) void {
        w.wasm_engine_delete(self.engine);
    }
};

const Store = struct {
    store: *w.wasmtime_store_t,

    pub fn init(engine: *const Engine) WasmError!Store {
        const store = w.wasmtime_store_new(engine.engine, null, null);

        return Store{
            .store = store orelse return WasmError.StoreInit,
        };
    }

    pub fn deinit(self: *const Store) void {
        defer w.wasmtime_store_delete(self.store);
    }
};

const Context = struct {
    context: *w.wasmtime_context_t,

    pub fn init(store: *const Store) WasmError!Context {
        const context = w.wasmtime_store_context(store.store);

        return Context{
            .context = context orelse return WasmError.ContextInit,
        };
    }
};

const Module = struct {
    module: *w.wasmtime_module_t,

    pub fn init(engine: *const Engine, wasm: *w.wasm_byte_vec_t) WasmError!Module {
        var module: ?*w.wasmtime_module_t = null;
        const err = w.wasmtime_module_new(engine.engine, wasm.data, wasm.size, &module);
        if (err != null) {
            return WasmError.ModuleInit;
        }

        return Module{
            .module = module orelse return WasmError.ModuleIsNull,
        };
    }

    pub fn deinit(module: *const Module) void {
        defer w.wasmtime_module_delete(module.module);
    }
};

const Instance = struct {
    instance: *w.wasmtime_instance_t,

    pub fn init(context: *const Context, module: *const Module) WasmError!Instance {
        const context_opt: ?*w.wasmtime_context_t = context.context;
        const module_opt: ?*const w.wasmtime_module_t = module.module;
        var instance: *w.wasmtime_instance_t = undefined;
        const instance_ptr: **w.wasmtime_instance_t = &instance;
        const instance_single_ptr: [*c]w.wasmtime_instance_t = @ptrCast(instance_ptr);
        // TODO: it looks a little bit laborious to get the right type...

        const err = w.wasmtime_instance_new(
            context_opt,
            module_opt,
            null, // We don't import anything for now
            0,
            instance_single_ptr,
            null, // Trap
        );
        if (err != null) {
            return WasmError.InstanceInit;
        }

        return Instance{
            .instance = instance,
        };
    }
};

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const engine = try Engine.init();
    defer engine.deinit();

    const store = try Store.init(&engine);
    defer store.deinit();

    const context = try Context.init(&store);

    // Load the WAT file
    const file = try std.fs.cwd().openFile("examples/wastime-c-bindings/gcd.wat", .{});
    defer file.close();

    // Get its size
    const fstat = try file.stat();
    const fsize = fstat.size;
    std.debug.print("File size = {d}\n", .{fsize});

    // Allocate memory for data.
    // TODO: check if it should be done using w.wasm_byte_vec_new_uninitialized...
    const binary: []u8 = try allocator.alloc(u8, fsize);
    defer allocator.free(binary);

    const bytes_read = try file.readAll(binary);
    std.debug.print("Bytes read = {d}\n", .{bytes_read});
    //std.debug.print("binary = {}\n", .{std.fmt.fmtSliceHexLower(binary)});

    const wat: w.wasm_byte_vec_t = .{
        .size = fsize,
        .data = binary.ptr,
    };

    // Parse the WAT into the binary WASM file
    var wasm: w.wasm_byte_vec_t = undefined;
    const ret = w.wasmtime_wat2wasm(wat.data, wat.size, &wasm);
    if (ret != null) {
        return WasmError.ParseWat;
    }

    // Compile and instantiate the module
    const module = try Module.init(&engine, &wasm);
    defer Module.deinit(&module);

    const instance = try Instance.init(&context, &module);
    _ = instance;

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
