# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust-based GPU fan control daemon that manages NVIDIA GPU fan curves based on temperature thresholds. The application:

- Reads TOML configuration files defining fan profiles with temperature curves
- Interfaces with Linux hwmon to control PWM fan speeds
- Uses the `libmedium` crate for hardware sensor management
- Listens on a network port for temperature reports from clients
- Supports multiple fan profiles with individual curves

## Architecture

### Core Components

- **main.rs**: Application entry point with CLI argument parsing, hwmon initialization, and main async runtime
- **config.rs**: Configuration schema definitions for fan profiles, curves, and setpoints
- **protocol.rs**: Network protocol definitions for client-server communication

### Key Data Structures

- `ServerConfig`: HashMap of profile names to `FanProfile` configurations
- `FanProfile`: Contains a list of fans and their temperature curve
- `State<T>`: Runtime state containing curve setpoints, fan handles, and current temperature
- `SetPoint`: Temperature/speed pairs defining the fan curve

## Development Commands

### Building and Running
```bash
# Build the project
cargo build

# Build optimized release
cargo build --release

# Run with default config
cargo run

# Run with custom config and verbose logging
cargo run -- -v /path/to/config.toml

# Run with specific listen address and port
cargo run -- -l 192.168.1.100 -p 8080 config.toml
```

### Development Tools
```bash
# Format code
cargo fmt

# Run linter
cargo clippy

# Check without building
cargo check

# Run tests (if any exist)
cargo test
```

### Nix Integration
This project is built with Nix flakes. The flake defines:

- A `fancontrol` package using crane for Rust builds
- Development shell with Rust toolchain, rust-analyzer, clippy, and rustfmt
- LLVM/Clang build dependencies

```bash
# Enter development shell
nix develop

# Build the package
nix build .#fancontrol
```

## Configuration

The application expects a `config.toml` file with the following structure:

```toml
[[profile_name.curve]]
temperature = 29  # Celsius
speed = 0         # 0-255 PWM value

[[profile_name.curve]]
temperature = 92
speed = 255

[[profile_name.fan]]
hwmon = 1  # hwmon1
fan = 3    # pwm3

[[profile_name.fan]]
hwmon = 1
fan = 5    # pwm5
```

## Network Protocol

The application listens for JSON messages on the configured port:

```json
{
  "type": "ReportTemperature",
  "profile": "nvidia",
  "temperature": 75.5
}
```

## Dependencies

Key external crates:
- `libmedium`: Hardware sensor interface for hwmon/PWM control
- `clap`: Command-line argument parsing
- `tokio`: Async runtime
- `serde`/`toml`: Configuration parsing
- `tracing`: Structured logging

## Error Handling

The application uses `thiserror` for structured error handling with specific error types for:
- Configuration loading/parsing issues
- Missing hwmon devices or fans
- Sensor parsing errors
- Logging setup failures