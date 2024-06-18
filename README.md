# [Z]ig & R[aylib]

## Overview

- Experimentation based on Zig and Raylib
- Have a look to *Wasm*. Currently there is no relation between *Zaylib* and *Wasm* but it could be nice to run *Wasm* into *Zaylib* ;)...
  - **wasm/** is standalone directory.
- To run *Zaylib* you will need to install *Raylib* header and library:
  - You need to build [Raylib](https://github.com/raysan5/raylib)
  - Create a repo called *raylib* (or modify *build.zig*)
  - Then copy the `raylib.h` and `libraylib.a` into the *raylib/* directory
  - As *Raylib* has a `build.zig` file it should be easy to build it with *Zaylib*
- Build & execute: `zig build && ./zig-out/bin/zaylib`

### Wasm in Zig
- We are using [wasmtime C API](https://docs.wasmtime.dev/c-api/).
  - We just untar the [release v21.0.1](https://github.com/bytecodealliance/wasmtime/releases/tag/v21.0.1) into the current directory.
  - We modified the `build.zig` file.

## Links

- https://github.com/zigwasm/wasmtime-zig
- https://github.com/malcolmstill/zware

## Next

- Can it be fun to have a game engine written in Zig while the game logic is a Wasm plugin.
- By doing this the game logic could be written in any langage that can generate wasm (Zig, Rust, C, ...)
- We will need a wasm runtime in C so it will be easy to load and run wasm in our Zig code
  - [wastime](https://github.com/bytecodealliance/wasmtime/)
  - [wasm3](https://github.com/wasm3/wasm3)
  - [wasmr](https://github.com/bytecodealliance/wasm-micro-runtime)
