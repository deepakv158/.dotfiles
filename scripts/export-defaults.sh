#!/usr/bin/env bash

# Export current macOS defaults settings
# This captures your CURRENT preferences so you can recreate them

EXPORT_DIR="$HOME/.dotfiles/exports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$EXPORT_DIR"

echo "Exporting current macOS defaults..."
echo "Output directory: $EXPORT_DIR"
echo ""

# Global/NSGlobalDomain settings (keyboard, trackpad, UI)
echo "📋 Exporting Global preferences..."
defaults read -g > "$EXPORT_DIR/NSGlobalDomain-$TIMESTAMP.txt"

# Trackpad settings
echo "🖱️  Exporting Trackpad preferences..."
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad > "$EXPORT_DIR/trackpad-$TIMESTAMP.txt" 2>/dev/null
defaults read com.apple.AppleMultitouchTrackpad > "$EXPORT_DIR/trackpad-builtin-$TIMESTAMP.txt" 2>/dev/null

# Keyboard settings
echo "⌨️  Exporting Keyboard preferences..."
defaults read com.apple.HIToolbox > "$EXPORT_DIR/keyboard-$TIMESTAMP.txt" 2>/dev/null

# Dock settings
echo "📱 Exporting Dock preferences..."
defaults read com.apple.dock > "$EXPORT_DIR/dock-$TIMESTAMP.txt"

# Finder settings
echo "📁 Exporting Finder preferences..."
defaults read com.apple.finder > "$EXPORT_DIR/finder-$TIMESTAMP.txt"

# Screenshots
echo "📸 Exporting Screenshot preferences..."
defaults read com.apple.screencapture > "$EXPORT_DIR/screencapture-$TIMESTAMP.txt" 2>/dev/null

# Safari
echo "🧭 Exporting Safari preferences..."
defaults read com.apple.Safari > "$EXPORT_DIR/safari-$TIMESTAMP.txt" 2>/dev/null

# Menu bar
echo "📊 Exporting Menu Bar preferences..."
defaults read com.apple.menuextra.clock > "$EXPORT_DIR/menubar-clock-$TIMESTAMP.txt" 2>/dev/null
defaults read com.apple.systemuiserver > "$EXPORT_DIR/systemuiserver-$TIMESTAMP.txt" 2>/dev/null

echo ""
echo "✅ Export complete!"
echo ""
echo "Files saved to: $EXPORT_DIR"
echo ""
echo "To view a file:"
echo "  cat $EXPORT_DIR/NSGlobalDomain-$TIMESTAMP.txt"
echo ""
echo "To search for a specific setting:"
echo "  grep -i 'keyword' $EXPORT_DIR/*.txt"
