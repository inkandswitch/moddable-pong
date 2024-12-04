# Build the Rust plugin
cd ./addons/patchwork/rust
cargo build || exit 1

# Change back to root directory and open Godot project
cd "../../.."

# Rust godot needs GODOT4_BIN
GODOT4_BIN=/Applications/Godot.app/Contents/MacOS/Godot 

# Launch project
${GODOT4_BIN} ./project.godot