# Firmware Core

This directory contains the core firmware for IoT devices, including:

- Hardware Watchdog (WDT) control logic
- Solid-State Relay (SSR) control
- Secure Element (SE) integration

## Build Requirements

- Rust toolchain (for Rust-based firmware)
- ARM GCC toolchain (for C-based firmware)
- OpenOCD (for flashing)

## Structure

```
firmware/
├── core/
│   ├── src/
│   │   ├── main.rs
│   │   ├── watchdog.rs
│   │   ├── ssr.rs
│   │   └── mqtt.rs
│   └── Cargo.toml
└── secure-element/
    ├── src/
    │   ├── lib.rs
    │   ├── se.rs
    │   └── crypto.rs
    └── Cargo.toml
```

## Building

```bash
# Build core firmware
cargo build --release

# Build secure element library
cargo build --release -p secure-element
```
