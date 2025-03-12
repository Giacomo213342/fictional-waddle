# ![polycule logo](assets/logo/logo-circle.svg) < polycule >

![< polycule > - a geeky and efficient \[matrix\] client for power users](assets/artwork/feature-graphic.svg)

[![Gitlab Pipeline Status](https://img.shields.io/gitlab/pipeline-status/polycule_client%2Fpolycule?style=for-the-badge&logo=gitlab)](https://gitlab.com/polycule_client/polycule/-/pipelines)
[![Weblate project translated](https://img.shields.io/weblate/progress/polycule?style=for-the-badge&logo=weblate)](https://hosted.weblate.org/projects/polycule/)
[![GitLab Tag](https://img.shields.io/gitlab/v/tag/polycule_client%2Fpolycule?style=for-the-badge&logo=gitlab)](https://gitlab.com/polycule_client/polycule/-/tags)

**Supports Open ID Connect :white_check_mark: !**

## About

Beep boop and I had too much time during boring work meetings. Using this client as
a small piece to practice some matrix related stuff.

I'm especially considering to experiment
with [Sliding Sync](https://github.com/matrix-org/matrix-spec-proposals/blob/kegan/sync-v3/proposals/3575-sync.md) and
Flutter Linux-native integrations.

## Features

- keyboard optimized
- accessibility focussed development
- no matrix.org !
- fast and efficient
- terminal style design
- cross-platform

See [Roadmap](#Roadmap) for feature parity details.

## Get < polycule >

As a Flutter application < polycule > is available on various platforms as native applications. Some are rather
experimental in support and not production ready. Consult the chart below for means of distribution and platform
specific project status.

| Platform         | Supported architectures              | Source                                                                                                                                                                                                              |       Stable       |
|------------------|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------:|
| Alpine Linux     | `AArch64`, `amd64`                   | [![Alpine Linux Testing](https://img.shields.io/badge/testing-brightgreen?style=for-the-badge&logo=alpinelinux&label=Alpine%20Linux)](https://pkgs.alpinelinux.org/packages?name=polycule&branch=edge&repo=testing) | :white_check_mark: |
| Arch Linux       | `AArch64`, `amd64`                   | [![AUR Version](https://img.shields.io/aur/version/polycule?style=for-the-badge&logo=archlinux)](https://aur.archlinux.org/packages/polycule)                                                                       | :white_check_mark: |
| Debian GNU/Linux | `AArch64`, `amd64`                   | [![DEB package from GitLab CI](https://img.shields.io/gitlab/v/tag/polycule_client%2Fpolycule?style=for-the-badge&logo=debian&label=DEB%20Package)](https://gitlab.com/polycule_client/polycule/-/tags)             |        :x:         |
| Android          | `arm64-v8a`, `armeabi-v7a`, `x86_64` | [![F-Droid Version](https://img.shields.io/f-droid/v/business.braid.polycule?style=for-the-badge&logo=fdroid)](https://f-droid.org/packages/business.braid.polycule/)                                               | :white_check_mark: |
| iOS              | iPhone, iPad, Apple Silicon Mac      | [![Apple TestFlight](https://img.shields.io/badge/Open_Beta-blue?style=for-the-badge&logo=apple&label=TestFlight)](https://gitlab.com/groups/polycule_client/-/epics/1)                                             |        :x:         |
| Web              | Firefox                              | [![Web app](https://img.shields.io/website?url=https%3A%2F%2Fpolycule.im%2Fweb&style=for-the-badge&logo=firefox)](https://polycule.im/web/)                                                                         |        :x:         |

## Screenshots

|                                                                             |                                                                              |                                                                                        |                                                                                         |
|-----------------------------------------------------------------------------|------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| ![Screenshot 1](assets/screenshots/linux/mobile/dark/01.png)                | ![Screenshot 2](assets/screenshots/linux/mobile/dark/02.png)                 | ![Screenshot 3](assets/screenshots/linux/mobile/dark/03.png)                           | ![Screenshot 4](assets/screenshots/linux/mobile/dark/04.png)                            |
| ![Screenshot 5](assets/screenshots/linux/mobile/dark/05.png)                | ![Screenshot 6](assets/screenshots/linux/mobile/dark/06.png)                 | ![Screenshot 7](assets/screenshots/linux/mobile/dark/07.png)                           | ![Screenshot 8](assets/screenshots/linux/mobile/dark/08.png)                            |
| ![Screenshot 9](assets/screenshots/linux/mobile/dark/09.png)                | ![Screenshot 10](assets/screenshots/linux/mobile/dark/10.png)                | ![Screenshot 11](assets/screenshots/android/tablet/light/01-homeserver.png)            | ![Screenshot 12](assets/screenshots/android/tablet/light/06-accessibility-settings.png) |
| ![Screenshot 13](assets/screenshots/android/desktop/dark/01-homeserver.png) | ![Screenshot 14](assets/screenshots/android/desktop/light/01-homeserver.png) | ![Screenshot 15](assets/screenshots/android/tablet/dark/06-accessibility-settings.png) | ![Screenshot 16](assets/screenshots/android/tablet/light/06-accessibility-settings.png) |

## Thanks

Thanks a lot to my wonderful previous coworkers maintaining
the [Matrix Dart SDK from Famedly](https://github.com/Famedly/matrix-dart-sdk/) and especially Krille, the kind author
of [FluffyChat](https://github.com/krille-chan/fluffychat).

< polycule > does not share any code directly with FluffyChat, both though build upon the same SDK. Some code though
might be quite similar in both clients - they both have a similar code base we know from some enterprise clients.

## Roadmap

| Feature                   |     Supported      |
|---------------------------|:------------------:|
| Homeserver selection      | :white_check_mark: |
| Homeserver proposals      | :white_check_mark: |
| HTTP/3 with QUIC          | :white_check_mark: |
| TLS hardening             | :white_check_mark: |
| Login                     |                    |
| ... native OIDC ready     | :white_check_mark: |
| ... password              | :white_check_mark: |
| ... SSO                   | :white_check_mark: |
| Multi account             |                    |
| ... routing               | :white_check_mark: |
| ... login                 | :white_check_mark: |
| ... incoming URI handling | :white_check_mark: |
| Room list                 | :white_check_mark: |
| Room timeline             | :white_check_mark: |
| Sliding sync              |        :x:         |
| Sending files             | :white_check_mark: |
| HTML renderer             | :white_check_mark: |
| User profiles             | :white_check_mark: |
| Room details              |        :x:         |
| Room settings             |        :x:         |
| Account settings          | :white_check_mark: |
| \[matrix\] widgets        |        :x:         |
| VoIP signaling            |        :x:         |
| Emoji picker              | :white_check_mark: |

## License

Like this project ? [Buy me a Coffee](https://www.buymeacoffee.com/braid).

This piece of software is published under the terms and conditions of the [EUPL-1.2](LICENSE).
