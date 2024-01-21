abstract class Version {
  const Version._();

  static const isStable = bool.fromEnvironment(
    'POLYCULE_IS_STABLE',
    defaultValue: false,
  );

  static const version = String.fromEnvironment(
    'POLYCULE_VERSION',
    defaultValue: 'debug',
  );

  static const author = 'The one with the braid';

  static const gitlabRepoBase = 'https://gitlab.com/polycule_client/polycule';

  static const stableChangeLog = '$gitlabRepoBase/-/tags/${Version.version}';

  static const commitList = '$gitlabRepoBase/-/commits/main';

  static const donationLink = 'https://www.buymeacoffee.com/braid';
}
