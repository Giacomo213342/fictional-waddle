with (import <nixpkgs> {
  config = {
    permittedInsecurePackages = [
      "olm-3.2.16"
    ];
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
    colima
    docker
    ideviceinstaller
    # olm
    # darwin.xcode_15_1
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
    # configure the dependency cache persistent
    export FLUTTER_VERSION="3.27.2"
    export FLUTTER_HOME="$HOME/build/flutter-$FLUTTER_VERSION"
    # export GEM_HOME="$HOME/build/gem"

    export FLUTTER_GIT_URL="unknown source"

    # ugly workaround to prevent use of nix-provided clang
    mkdir -p "$HOME/.bin"
    ln -sf /usr/bin/clang "$HOME/.bin"
    ln -sf /usr/bin/clang++ "$HOME/.bin"
    ln -sf /usr/bin/sed "$HOME/.bin"
    ln -sf /usr/bin/tar "$HOME/.bin"

    # ensure we use the system xcrun
    ln -sf /usr/bin/xcrun "$HOME/.bin"

    export LANG=en_US.UTF-8

    # create a clean build environment for our Python toolchain
    rm -rf .buildenv
    python -m virtualenv .buildenv

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

    export PATH="$HOME/.bin:$GEM_HOME/bin:$DEVELOPER_DIR/usr/bin:$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$FLUTTER_HOME/bin:$PATH:/usr/sbin:/usr/bin"

    if [ ! -f "$FLUTTER_HOME/bin/flutter" ]; then
      git clone -b $FLUTTER_VERSION --depth 1 https://github.com/flutter/flutter.git $FLUTTER_HOME
      flutter --suppress-analytics precache --universal --ios --macos
    fi

    flutter --disable-analytics
    dart --disable-analytics

    source .buildenv/bin/activate
    pip install codemagic-cli-tools

    gem install --update xcodeproj
    pod repo update

    # ugly workaround for olm: copy it so that flutter finds it
    # basically finds the dylib of olm and copies it to current working directory
    # we search in the path of nix ldflags to find the two libraries we need
    # as the path in the $NIX_LDFLAGS starts with '-L' we need to remove this otherwise the path
    # can't be parsed

    # find $(echo $NIX_LDFLAGS | sed 's/-L//g' | uniq) -name "libolm.3.dylib" -print -quit | xargs -I{} cp -f {} $(pwd)
    cp -f /usr/local/Cellar/libolm/*/lib/libolm.3.dylib $(pwd)
    find $(echo $NIX_LDFLAGS | sed 's/-L//g' | uniq) -name "libcrypto.3.dylib" -print -quit | xargs -I{} cp -f {} $(pwd)

    # https://github.com/abiosoft/colima/issues/1036
    # export LIMA_HOME=~/.colima_lima
    # colima start

  '';
}
