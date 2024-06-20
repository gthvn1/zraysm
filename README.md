# [Z]ig & R[aylib]

## Overview

- Experimentation around Zig, Raylib and Wasm.
- A game in Zig using Raylib bindings and allowing plugins written in Wasm...
- Currently we are able to use Raylib and build a small WAT file.

## Installation

- To use *Zaylib* you will need to install *Raylib* header and library:
  - You need to build [Raylib](https://github.com/raysan5/raylib)
  - Create a directory called *raylib* (or modify *build.zig*)
  - Then copy the `raylib.h` and `libraylib.a` into the *raylib/* directory
  - As *Raylib* has a `build.zig` file it should be easy to build it with *Zaylib*
- We are using *Wasmer*.
  - So you will need to download [Wasmer](https://github.com/wasmerio/wasmer/releases)
  - Create a directory *wasmer*
  - go into the directory and untar the previously downloaded release
    - we only need `lib/libwasmer.so` and the `include/*` but you can keep other stuff- We have an issue using `libwasmer.a` so to run it: `zig build && LD_LIBRARY_PATH=./wasmer/lib ./zig-out/bin/zaylib` 

## Changelog

2024-06-20  Gthvn1  <gthvn1@gmail.com>

  * Run a WAT string into our Zig code using Wasmer

2024-06-17  Gthvn1  <gthvn1@gmail.com>

  * Add examples of wasmtime C API
    * don't know if we will use wasmtime or another runtime.

2024-06-15  Gthvn1  <gthvn1@gmail.com>

  * Add simple example of using WAT file into HTML
    * It runs outside of Zig
  * Link our program with Raylib
  * Calling a C function from Zig (see foo)
  * Initial commit
