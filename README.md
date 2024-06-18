# ![polycule logo](assets/logo/logo-circle.svg) < polycule >

A geeky and efficient \[matrix\] client for power users.

## About

**Is it usable yet ? - No. Absolutely not.**

See [Roadmap](#Roadmap) for feature details.

Beep boop and I had too much time during boring work meetings. Using this client as
a small piece to practice some matrix related stuff.

I'm especially considering to experiment
with [Sliding Sync](https://github.com/matrix-org/matrix-spec-proposals/blob/kegan/sync-v3/proposals/3575-sync.md) and
Flutter Linux-native integrations.

## Features

- keyboard optimized
- no matrix.org !
- fast and efficient
- terminal style design
- cross-platform

## Preview

You can try to web-builds hosted on [GitLab pages](https://polycule.im/web/) or download some
Linux builds from the CI jobs.

## Thanks

Thanks a lot to my wonderful previous coworkers maintaining
the [Matrix Dart SDK from Famedly](https://github.com/Famedly/matrix-dart-sdk/) and especially Krille, the kind author
of [FluffyChat](https://github.com/krille-chan/fluffychat).

< polycule > does not share any code directly with FluffyChat, both though build upon the same SDK. Some code though
might be quite similar in both clients - they both have a similar code base we know from some enterprise clients.

## Roadmap

| Feature                   |             Supported             |
|---------------------------|:---------------------------------:|
| Homeserver selection      |        :check_mark_button:        |
| Homeserver proposals      |        :check_mark_button:        |
| Login                     |                                   |
| ... password              |        :check_mark_button:        |
| ... SSO                   |        :cross_mark_button:        |
| ... native OIDC ready     |        :cross_mark_button:        |
| Multi account             |                                   |
| ... routing               |        :check_mark_button:        |
| ... login                 |        :check_mark_button:        |
| ... incoming URI handling |        :cross_mark_button:        |
| Room list                 | :record_button: - bad performance |
| Room timeline             | :record_button: - bad performance |
| Sliding sync              |        :cross_mark_button:        |
| Sending files             |        :cross_mark_button:        |
| HTML renderer             |   :record_button: - early state   |
| User profile              |        :cross_mark_button:        |
| Room details              |        :cross_mark_button:        |
| Account settings          |        :cross_mark_button:        |
| \[matrix\] widgets        |        :cross_mark_button:        |
| VoIP signaling            |        :cross_mark_button:        |
| Emoji picker              |        :cross_mark_button:        |

*Can you daily drive it ?* - Yes, I do.

## License

This piece of software is published under the terms and conditions of the [EUPL-1.2](LICENSE).
