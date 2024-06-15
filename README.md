# Zig & Raylib

- Experimentation based on Zig and Raylib
- Have a look to *Wasm*. Currently there is no relation between *Zaylib* and *Wasm* but it could be nice to run *Wasm* into *Zaylib* ;)...
  - **wasm/** is standalone directory.
- To run *Zaylib* you will need to install *Raylib* header and library:
  - You need to build [Raylib](https://github.com/raysan5/raylib)
  - Create a repo called *raylib* (or modify *build.zig*)
  - Then copy the `raylib.h` and `libraylib.a` into the *raylib/* directory
  - As *Raylib* has a `build.zig` file it should be easy to build it with *Zaylib*
- Build & execute: `zig build && ./zig-out/bin/zaylib`
