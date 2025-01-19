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
- [Olm](https://gitlab.matrix.org/matrix-org/olm/) (`libolm.so.3`)

### Flutter

Flutter is currently packaged as Alpine package or as SNAP. The Arch User Repository also ships build files for it. On
other distributions or operating systems, please check [docs.flutter.dev](https://docs.flutter.dev/get-started/install).

### Don't know Flutter ?

In case you don't know Flutter, how about contributing to the translations
on [Weblate](https://hosted.weblate.org/projects/polycule/) ?

### Olm

Olm is used for the matrix related cryptography. You will only need to install it when deeloping for Desktops.

Olm is packaged on pretty any package manager on Linux, Windows and macOS.

**Important** : For building or running the web version, you will need to download the JS/WASM version of OLM. Use the
following script to download the matching version.

```shell
# ensure the command `yq` is installed on your system
which yq
# download OLM for web
./scripts/download-olm.sh
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
  `pacman -S gtk3 openssl libsecret mimalloc mpv && pacman -S xdg-user-dirs dbus mpv mimalloc libnotify libolm`
- For Fedora, install :
  `dnf install gtk3-devel openssl-devel libsecret-devel mimalloc-devel mpv-devel && dnf install xdg-user-dirs dbus mpv mimalloc libnotify libolm`
- For Debian/Ubuntu, install :
  `apt install libgtk-3-dev libssl-dev libsecret-1-dev libmimalloc-dev libmpv-dev && apt install xdg-user-dirs dbus mpv libmimalloc2.0 libnotify-bin libolm`
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

## Building < polycule >

### Web worker for web

If you want to run < polycule > for web, ensure you build the web worker first.

```shell
dart compile js -o web/web_worker.dart.js -m web/web_worker.dart
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

