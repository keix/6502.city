# 6502.city — Nyxx feat. JavaScript

**6502.city** where Read-Only becomes Reply-On. It is a WebGL frontend for [Nyxx](https://github.com/keix/nyxx).

## What is 6502.city?
6502.city dynamically constructs **virtual ROM** images from runtime data. Unlike traditional systems that load a fixed ROM, here the ROM itself is built in-browser — byte by byte — based on API responses or scripted logic.

This ROM is then **injected into Nyxx’s virtual memory map** and executed as if it had always existed.

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
- JavaScript constructs or modifies the ROM contents dynamically
- Serialized API responses or hand-written opcodes are placed directly into the ROM region
- Nyxx runs the updated ROM, unaware it was just written

This allows:
- Real-time, programmable ROM content
- Reactive systems (e.g. AI-assisted dialogue, branching logic)
- Full 8-bit compatibility — no spec violations, no magic

## Dreams, in Opcodes
6502.city is a tribute to cartridges that were never released. The 8-bit AI cartridge I dreamed of as a child was never built. The 2A03 was discontinued, and that dream faded — but not forever.  

Today, I deployed what never shipped.

## Deployment

Deployed using AWS CDK. Static frontend, dynamic ROMs, zero backend compute.

## Live Demo

Coming soon: [https://6502.city](https://6502.city)

> **You don’t need an assembler to dream in opcodes.**
