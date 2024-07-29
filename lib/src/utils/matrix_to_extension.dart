import 'package:matrix/matrix.dart';

extension MatrixToExtension on MatrixIdentifierStringExtensionResults {
  String toMatrixToUrl() {
    String uri = 'https://matrix.to/#/$primaryIdentifier';
    final secondary = secondaryIdentifier;
    if (secondary is String) {
      uri += '/$secondary';
    }
    final query = queryString;
    if (query is String) {
      uri += '?$query';
    }
    return uri;
  }
}
