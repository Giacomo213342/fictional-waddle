with (import <nixpkgs> {});

let
  inputs = [
    curl
    cacert
    unzip
    git
    sqlite
    sqlcipher
    olm
    coreutils
    # darwin.xcode_15_1
    ruby
    python3
    python3Packages.virtualenv
    ];
in mkShell {
  buildInputs = inputs;
  shellHook =
  ''
    # configure the dependency cache persistent
    export FLUTTER_VERSION="3.24.3"
    export FLUTTER_HOME="$HOME/build/flutter-$FLUTTER_VERSION"
    export GEM_HOME="$HOME/build/gem"

    # ugly workaround to prevent use of nix-provided clang
    mkdir -p "$HOME/.bin"
    ln -sf /usr/bin/clang "$HOME/.bin"
    ln -sf /usr/bin/clang++ "$HOME/.bin"
    # same for package:media_kit relying on bsdtar
    ln -sf /usr/bin/tar "$HOME/.bin"
    ln -sf /usr/bin/cut "$HOME/.bin"
    ln -sf /usr/bin/sed "$HOME/.bin"

    export LANG=en_US.UTF-8

    # create a clean build environment for our Python toolchain
    python -m virtualenv .buildenv

    # export XCODE_HASH="hvqfks6vchhg3pzszqs064hy27cxws3q"
    # export XCODE_APP="/nix/store/$XCODE_HASH-Xcode.app"

    export XCODE_APP="/Applications/Xcode.app"

    sudo /usr/bin/xcode-select -s "$XCODE_APP"
    sudo /usr/bin/xcodebuild -license accept
    sudo /usr/bin/xcodebuild -runFirstLaunch
    sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true

    xcodebuild -quiet -downloadPlatform iOS

    # ensure we have the system linker and compile in first position of PATH
    export LD="/usr/bin/clang"
    export PATH="$HOME/.bin:$GEM_HOME/bin:$XCODE_APP/Contents/Developer/usr/bin:$FLUTTER_HOME/bin:$PATH:/usr/sbin:/usr/bin"

    if [ ! -f "$FLUTTER_HOME/bin/flutter" ]; then
      git clone -b $FLUTTER_VERSION --depth 1 https://github.com/flutter/flutter.git $FLUTTER_HOME
      flutter --suppress-analytics precache --universal --ios --macos
    fi

    flutter --disable-analytics

    source .buildenv/bin/activate
    pip install codemagic-cli-tools

    gem install --update cocoapods
    pod repo update
  '';
}
