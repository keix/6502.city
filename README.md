# 6502.city — Nyxx feat. JavaScript

**6502.city** where Read-Only becomes Reply-On. It is a WebGL frontend for [Nyxx](https://github.com/keix/nyxx).

## What is 6502.city?
This project showcases a minimal WebAssembly runtime for 6502 programs, powered by a Zig-written emulator and a WebGL renderer.

At present, the ROM is precompiled from a static Zig array — no assembler is used. The instruction sequence is directly serialized into a binary blob during the Zig build and mapped into Nyxx’s virtual memory space ($8000–$FFFF).

No assembler.  
No illusion.  
Just memory, redefined.

## Key Features

- **Dynamic ROM synthesis** in JavaScript
- **Memory-mapped ROM emulation** via Nyxx (WASM)
- **WebGL frontend** for native-feeling, pixel-perfect rendering
- Runs entirely in your browser — no installs, no plugins

## Architecture
- Nyxx exposes a **virtual ROM area** (e.g. `$8000–$FFFF`)
- Serialized API responses or hand-written opcodes are placed directly into the ROM region

## Live Demo

Coming soon: [https://6502.city](https://6502.city)

> **You don’t need an assembler to dream in opcodes.**
