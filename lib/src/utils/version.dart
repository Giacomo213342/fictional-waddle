import 'dart_environment.dart';

abstract class Version {
  const Version._();

  static const author = 'The one with the braid';

  static const gitlabRepoBase = 'https://gitlab.com/polycule_client/polycule';

  static const stableChangeLog =
      '$gitlabRepoBase/-/tags/${DartEnvironment.polyculeVersion}';

  static const commitList = '$gitlabRepoBase/-/commits/main';

  static const donationLink = 'https://www.buymeacoffee.com/braid';
}
