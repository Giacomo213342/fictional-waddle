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
| Homeserver selection      |        :white_check_mark:         |
| Homeserver proposals      |        :white_check_mark:         |
| Login                     |                                   |
| ... password              |        :white_check_mark:         |
| ... SSO                   |   :negative_squared_cross_mark:   |
| ... native OIDC ready     |   :negative_squared_cross_mark:   |
| Multi account             |                                   |
| ... routing               |        :white_check_mark:         |
| ... login                 |        :white_check_mark:         |
| ... incoming URI handling |   :negative_squared_cross_mark:   |
| Room list                 | :record_button: - bad performance |
| Room timeline             | :record_button: - bad performance |
| Sliding sync              |   :negative_squared_cross_mark:   |
| Sending files             |   :negative_squared_cross_mark:   |
| HTML renderer             |   :record_button: - early state   |
| User profile              |   :negative_squared_cross_mark:   |
| Room details              |   :negative_squared_cross_mark:   |
| Account settings          |   :negative_squared_cross_mark:   |
| \[matrix\] widgets        |   :negative_squared_cross_mark:   |
| VoIP signaling            |   :negative_squared_cross_mark:   |
| Emoji picker              |   :negative_squared_cross_mark:   |

*Can you daily drive it ?* - Yes, I do.

## License

This piece of software is published under the terms and conditions of the [EUPL-1.2](LICENSE).
