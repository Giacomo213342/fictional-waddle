with (import <nixpkgs> {
  config = {
    allowUnfree = true;
  };
});

let
  inputs = [
    curl
    cacert
    unzip
    git
    sqlite
    sqlcipher
    coreutils
    docker
    ideviceinstaller
    rustup
    ruby
    cocoapods
    python3
    python3Packages.virtualenv
    xcpretty
    ];
in mkShell {
  buildInputs = inputs;
  shellHook =
  ''
    # ugly workaround to prevent use of nix-provided clang
    mkdir -p "$HOME/.bin"
    ln -sf /usr/bin/clang "$HOME/.bin"
    ln -sf /usr/bin/clang++ "$HOME/.bin"
    ln -sf /usr/bin/sed "$HOME/.bin"
    ln -sf /usr/bin/tar "$HOME/.bin"

    # ensure we use the system xcrun
    ln -sf /usr/bin/xcrun "$HOME/.bin"

    # export XCODE_HASH="hvqfks6vchhg3pzszqs064hy27cxws3q"
    # export XCODE_APP="/nix/store/$XCODE_HASH-Xcode.app"
    export XCODE_APP="/Applications/Xcode.app"

    # these environment variables override the xcode-select location for some tools, manually overriding
    export DEVELOPER_DIR="$XCODE_APP/Contents/Developer"
    export SDKROOT="$DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

    sudo xcode-select -s "$DEVELOPER_DIR"
    sudo xcodebuild -license accept
    sudo xcodebuild -runFirstLaunch
    sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license

    xcodebuild -quiet -downloadPlatform iOS

    # ensure we have the system linker and compile in first position of PATH
    export LD="/usr/bin/clang"

    export PATH="$HOME/.bin:$DEVELOPER_DIR/usr/bin:$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH:/usr/sbin:/usr/bin"

    # we search in the path of nix ldflags to find the libcrypto library we need
    # as the path in the $NIX_LDFLAGS starts with '-L' we need to remove this otherwise the path
    # can't be parsed

    find $(echo $NIX_LDFLAGS | sed 's/-L//g' | uniq) -name "libcrypto.3.dylib" -print -quit | xargs -I{} cp -f {} $(pwd)

  '';
}
