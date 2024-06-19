const std = @import("std");

const w = @cImport({
    @cInclude("wasi.h");
    @cInclude("wasm.h");
    @cInclude("wasmtime.h");
});

pub const WasmError = error{
    EngineInit,
    StoreInit,
    ContextInit,
    ModuleOpenWat,
    ModuleFileStat,
    ModuleMemAlloc,
    ModuleReadWat,
    ModuleInit,
    ModuleIsNull,
    InstanceMem,
    InstanceInit,
    ParseWat,
    ExportGet,
    ExternFunc,
};

pub const Engine = struct {
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

pub const Store = struct {
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

pub const Context = struct {
    context: *w.wasmtime_context_t,

    pub fn init(store: *const Store) WasmError!Context {
        const context = w.wasmtime_store_context(store.store);

        return Context{
            .context = context orelse return WasmError.ContextInit,
        };
    }
};

pub const Module = struct {
    module: *w.wasmtime_module_t,

    pub fn init(engine: *const Engine, watfile: []const u8) WasmError!Module {
        // Load the WAT file
        const file = std.fs.cwd().openFile(watfile, .{}) catch return WasmError.ModuleOpenWat;
        defer file.close();

        // Get its size
        const fstat = file.stat() catch return WasmError.ModuleFileStat;
        const fsize = fstat.size;
        std.debug.print("File size = {d}\n", .{fsize});

        // Allocate memory for data.
        // TODO: check if it should be done using w.wasm_byte_vec_new_uninitialized...
        const allocator = std.heap.c_allocator;
        const binary: []u8 = allocator.alloc(u8, fsize) catch return WasmError.ModuleMemAlloc;
        defer allocator.free(binary);

        const bytes_read = file.readAll(binary) catch return WasmError.ModuleReadWat;
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

pub const Instance = struct {
    instance: []w.wasmtime_instance_t,
    context: *w.wasmtime_context_t,
    allocator: std.mem.Allocator,

    pub fn init(context: *const Context, module: *const Module, allocator: std.mem.Allocator) WasmError!Instance {
        const context_opt: ?*w.wasmtime_context_t = context.context;
        const module_opt: ?*const w.wasmtime_module_t = module.module;
        const instance = allocator.alloc(w.wasmtime_instance_t, 1) catch return WasmError.InstanceMem;
        //const instance_ptr: **w.wasmtime_instance_t = &instance;
        //const instance_single_ptr: [*c]w.wasmtime_instance_t = @ptrCast(instance_ptr);
        // TODO: it looks a little bit laborious to get the right type...

        //pub extern fn wasmtime_module_new(
        //  engine: ?*wasm_engine_t,
        //  wasm: [*c]const u8,
        //  wasm_len: usize,
        //  ret: [*c]?*wasmtime_module_t) ?*wasmtime_error_t;
        //pub extern fn wasmtime_instance_new(
        //  store: ?*wasmtime_context_t,
        //  module: ?*const wasmtime_module_t,
        //  imports: [*c]const wasmtime_extern_t,
        //  nimports: usize,
        //  instance: [*c]wasmtime_instance_t,
        //  trap: [*c]?*wasm_trap_t) ?*wasmtime_error_t;
        const err = w.wasmtime_instance_new(context_opt, module_opt, null, 0, instance.ptr, null);
        if (err != null) {
            return WasmError.InstanceInit;
        }

        return Instance{
            .instance = instance,
            .context = context.context,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *const Instance) void {
        self.allocator.free(self.instance);
    }

    pub fn get_export(self: *const Instance, name: []const u8, item: *w.wasmtime_extern_t) WasmError!void {
        const context_opt: ?*w.wasmtime_context_t = self.context;
        const item_ptr: [*c]w.wasmtime_extern_t = @ptrCast(item);

        const ok: bool = w.wasmtime_instance_export_get(context_opt, self.instance.ptr, name.ptr, name.len, item_ptr);
        if (!ok) {
            return WasmError.ExportGet;
        }

        if (item.kind != w.WASMTIME_EXTERN_FUNC) {
            return WasmError.ExternFunc;
        }
    }
};
