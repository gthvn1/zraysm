#!/bin/bash

# compile wasm file: `wat2wasm add.wat -o add.wasm`
# start python web server: `python3 -m http.server`
wat2wasm add.wat -o add.wasm && python3 -m http.server
