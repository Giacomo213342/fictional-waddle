with (import <nixpkgs> {});

let
  inputs = [
    curl
    cacert
    unzip
    git
    sqlite
    sqlcipher
    coreutils
    darwin.xcode_15_1
    ruby
    cocoapods
    # darwin.apple_sdk.frameworks.AppKit
    # darwin.apple_sdk.frameworks.AVFoundation
    # darwin.apple_sdk.frameworks.Cocoa
    # darwin.apple_sdk.frameworks.CoreMedia
    # darwin.apple_sdk.frameworks.Foundation
    ];
in mkShell {
  buildInputs = inputs;
  shellHook =
  ''
    # configure the dependency cache persistent
    export FLUTTER_VERSION="3.22.2"
    export FLUTTER_HOME="$HOME/build/flutter-$FLUTTER_VERSION"

    # ugly workaround to prevent use of nix-provided clang
    mkdir -p "$HOME/.bin"
    ln -sf /usr/bin/clang "$HOME/.bin"
    ln -sf /usr/bin/clang++ "$HOME/.bin"

    export LANG=en_US.UTF-8

    export XCODE_HASH="hvqfks6vchhg3pzszqs064hy27cxws3q"
    export XCODE_APP="/nix/store/$XCODE_HASH-Xcode.app"

    sudo xcode-select -s "$XCODE_APP"
    sudo xcodebuild -license accept
    sudo xcodebuild -runFirstLaunch
    xcodebuild -downloadPlatform iOS

    # ensure we have the system linker and compile in first position of PATH
    export LD="/usr/bin/clang"
    export PATH="$HOME/.bin:$XCODE_APP/Contents/Developer/usr/bin:$FLUTTER_HOME/bin:$PATH:/usr/sbin:/usr/bin"
    
    if [ ! -f "$FLUTTER_HOME/bin/flutter" ]; then
      git clone -b $FLUTTER_VERSION --depth 1 https://github.com/flutter/flutter.git $FLUTTER_HOME
      flutter precache --universal --ios --macos
      flutter config --no-analytics
    fi
  '';
}
