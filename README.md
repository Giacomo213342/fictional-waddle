

# ![polycule logo](assets/logo/logo-circle.svg) A vibe-coded version of < polycule >
## Why?
I created this personal project just to use it with [mautrix-whatsapp](https://github.com/Giacomo213342/mautrix-whatsapp) as GrapheneOS has issues with Whatsapp's Play Integrity checks, I didn't really like any of the commercial clients but when I saw < polycule > I liked it so much.
This project is fully vibe-coded, I am not a Dart developer, I don't really recommend using it unless you are ready to experience bugs and general issues (still, it should be less broken than the original abandoned version of < polycule >).
I decided to publish this just because I think you can get a smoother experience if you like < polycule >'s UI style. If you don't like the fact this is made with AI, I understand it, I don't like it either, but I needed to get something to work else I couldn't text my friends and family (also because of the terrible proxy support in clients like Faraday).

## Umm, ok I guess... But what do I get?
### General features
- Socks5 proxy support
- System navigation (gestures, buttons, etc) implementation
- A dark OLED theme
- Removal of the multi-account system
- Bottom bar removal
- VoIP implementation (see [my version of mautrix-whatsapp](https://github.com/Giacomo213342/mautrix-whatsapp), which is vibe-coded as well)
- SQLite bug fixes, which caused disconnections and broke the whole experience
- Notifications improvements and fixes
- General interface optimizations and edits to allow for a smoother experience
- Many, many, many more critical bug fixes
### Room features
- Unread message dividers
- Clicking on replies brings you to the quoted message
- Read, typing, edited indicator implementations (very simple, set up to work with mautrix)
- Polls
- Images and videos are opened full-screen when played and can be zoomed/downloaded
- Voice messages are implemented better and allow speeding up or slowing down the speed
- Timestamp edits to show the full time on older messages
## Note: some stuff can still be a little broken *(mostly due to bugs in the original code)*, but I don't feel like it's too much of an issue with general everyday use.
### I won't implement stuff not related to < polycule > + mautrix usage. I mean, if I can do it with AI you can too, right?
#
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
| Web              | Firefox                              | [![Web app](https://img.shields.io/website?url=https%3A%2F%2Fpolycule.im%2Fweb&style=for-the-badge&logo=firefox)](https://polycule.im/web/)                                                                         | :white_check_mark: |

## Screenshots

### Linux mobile

|                                                              |                                                               |                                                              |                                                              |
|--------------------------------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------|--------------------------------------------------------------|
| ![Screenshot 1](assets/screenshots/linux/mobile/dark/01.png) | ![Screenshot 2](assets/screenshots/linux/mobile/dark/02.png)  | ![Screenshot 3](assets/screenshots/linux/mobile/dark/03.png) | ![Screenshot 4](assets/screenshots/linux/mobile/dark/04.png) |
| ![Screenshot 5](assets/screenshots/linux/mobile/dark/05.png) | ![Screenshot 6](assets/screenshots/linux/mobile/dark/06.png)  | ![Screenshot 7](assets/screenshots/linux/mobile/dark/07.png) | ![Screenshot 8](assets/screenshots/linux/mobile/dark/08.png) |
| ![Screenshot 9](assets/screenshots/linux/mobile/dark/09.png) | ![Screenshot 10](assets/screenshots/linux/mobile/dark/10.png) |                                                              |                                                              |

### Android

| Dark terminal theme (tablet)                                                                    | Light rose theme (tablet)                                                                        |
|-------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| ![Welcome screen](assets/screenshots/android/tablet/dark/01-homeserver.png)                     | ![Welcome screen](assets/screenshots/android/tablet/light/01-homeserver.png)                     |
| ![Legacy login](assets/screenshots/android/tablet/dark/10-login-legacy.png)                     | ![Legacy login](assets/screenshots/android/tablet/light/10-login-legacy.png)                     |
| ![Commands](assets/screenshots/android/tablet/dark/15-commands.png)                             | ![Commands](assets/screenshots/android/tablet/light/15-commands.png)                             |
| ![Room](assets/screenshots/android/tablet/dark/16-emojis.png)                                   | ![Room](assets/screenshots/android/tablet/light/16-emojis.png)                                   |
| ![Account settings](assets/screenshots/android/tablet/dark/13-emoji-settings.png)               | ![Account settings](assets/screenshots/android/tablet/light/13-emoji-settings.png)               |
| ![Accessibility settings](assets/screenshots/android/tablet/dark/04-accessibility-settings.png) | ![Accessibility settings](assets/screenshots/android/tablet/light/04-accessibility-settings.png) |

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
| VoIP signaling            | :white_check_mark: |
| Emoji picker              | :white_check_mark: |

## License

Like this project ? [Buy me a Coffee](https://www.buymeacoffee.com/braid).

This piece of software is published under the terms and conditions of the [EUPL-1.2](LICENSE).
