## Contributing to < polycule >

It's easier than you think. < polycule > does not require any complex development environment.

What you need for development toolchain :

- [Flutter](https://flutter.dev/)
- [GTK 3](https://www.gtk.org/)
- [OpenSSL](https://www.openssl.org/)
- [libsecret](https://gitlab.gnome.org/GNOME/libsecret)
- [mimalloc](https://github.com/microsoft/mimalloc)
- [mpv](https://mpv.io/)

Additionally, you will need the following Linux runtime dependencies :

- [xdg-user-dirs](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/) (command `xdg-user-dirs`)
- [libnotify](https://gitlab.gnome.org/GNOME/libnotify) (command `notify-send`)
- [dbus](https://www.freedesktop.org/wiki/Software/dbus/) (`libdbus-1.so.3`)

### Flutter

Flutter is currently packaged as Alpine package or as SNAP. The Arch User Repository also ships build files for it. On
other distributions or operating systems, please check [docs.flutter.dev](https://docs.flutter.dev/get-started/install).

### Don't know Flutter ?

In case you don't know Flutter, how about contributing to the translations
on [Weblate](https://hosted.weblate.org/projects/polycule/) ?

### Vodozemac

Vodozemac is used for the matrix related cryptography.

Vodozemac is automatically bundled on all platforms except for web. Use the following steps to build it for web :

```shell
# ensure the command `rustup` is installed on your system
which rustup
cargo install flutter_rust_bridge_codegen
cargo install wasm-pack

flutter pub get

# ensure the command `yq` is installed on your system
which yq
# compile vodozemac for web
./scripts/compile-vodozemac-wasm.sh
```

### OpenSSL

Database encryption requires OpenSSL to be installed on your system both for development and at runtime.

### libsecret

On Linux, you will need libsecret in order to compile the applications and a running keyring daemon in order to run the
application.

### mvp

On desktops, mpv is used for multimedia playback. Ensure it's both available as development library and as runtime
shared object.

### mimalloc

On Linux, we use mimalloc as allocator in order to prevent memory leaks. mimalloc is packaged for pretty much any Linux
distribution and required as runtime shared object.

## Linux desktop TL;DR

- For Arch Linux, install :
  `pacman -S gtk3 openssl libsecret mimalloc mpv && pacman -S xdg-user-dirs dbus mpv mimalloc libnotify`
- For Fedora, install :
  `dnf install gtk3-devel openssl-devel libsecret-devel mimalloc-devel mpv-devel && dnf install xdg-user-dirs dbus mpv mimalloc libnotify`
- For Debian/Ubuntu, install :
  `apt install libgtk-3-dev libssl-dev libsecret-1-dev libmimalloc-dev libmpv-dev && apt install xdg-user-dirs dbus mpv libmimalloc2.0 libnotify-bin`
- Development on musl-based distributions is currently not possible

## Setting up your development environment

### Editors

Flutter has decent integration into the IntelliJ-based IDES (such as IDEA or Android Studio), Microsoft Visual Studio
Code based editors and vim based editors. Check your search engine of choice for the setup.

### Translations and String resources

Never hard code any Strings into the code. All Strings should be listed in `lib/l10n/arb/app_en.arb` - as well as any
other language you might want to translate for.

After changing or adding a String resource, execute the following command in order to make it accessible in your Dart
code.

```shell
flutter gen-l10n
```

### Code style

We use dartfmt in order to have all files properly formated. Additionally, we use
[`package:import_sorter`](https://pub.dev/packages/import_sorter) for managing imports.

Use the following lines of code to ensure your code is properly foratted.

```shell
# ensure all linter recommendations are applied
dart fix --apply
# check whether there's anything left the linter could not fix automatically
dart analyze --fatal-infos
# format the code according to our preferences
dart format .
# sort the imports
dart run import_sorter:main --no-comments
```

### Integration tests

For testing < polycule >, you will need an Android emulator and Docker. Linux desktop and mobile integration tests are
under development but so far hard to run in CI. All tests work on Linux but since they won't be verified in the
< polycule > GitLab CI, It's not recommended to rely on them.

For simplicity, it's recommended to use the < polycule > CI Android emulator OCI images since they provide a
reproducible test environment.

Please
check [the OCI emulator docs](https://gitlab.com/polycule_client/flutter-dockerimages/#using-the-android-emulator) for
further details.

#### Prepare

```shell
# start a homeserver listening on your Docker network IP
HOMESERVER=10.10.0.1 ./integration_test/server/conduit.sh

# register alice and bob at our Conduit
HOMESERVER=http://10.10.0.1 dart integration_test/server/prepare_legacy.dart

# prepare your Android emulator
./scripts/emulator-android.sh
```

#### Debug integration tests

```shell
# check which device ID to run on
flutter devices
HOMESERVER=http://10.10.0.1 flutter test -d your_device \
    integration_test/integration.dart \
    --dart-define=HOMESERVER=$HOMESERVER \
    --dart-define=POLYCULE_IS_INTEGRATION_TEST=true
```

### Run profile integration tests

Integration tests in profile mode use a separate driver to store screenshots of each testes page. The screenshots will
be locally accessible in `assets/screenshots/*/mobile`.

```shell
# check which device ID to run on
flutter devices
HOMESERVER=http://10.10.0.1 flutter drive -d your_device --profile \
    --driver test_driver/integration_test.dart \
    --target integration_test/integration.dart \
    --dart-define=HOMESERVER=$HOMESERVER \
    --dart-define=POLYCULE_IS_INTEGRATION_TEST=true
```

## Building < polycule >

### Web worker for web

If you want to run < polycule > for web, ensure you build the web worker first.

```shell
dart compile js web/web_worker.dart -m -o web/pkg/web_worker.dart.js
```

### Running in debug mode

```shell
flutter run
```

### Building a (more or less) stable build

```shell
# decide which platform to build for, e.g. linux, web, apk, appbundle, ios, ipa, macos, windows or winuwp
export PLATFORM=linux
flutter build $PLATFORM
```

Enjoy !

