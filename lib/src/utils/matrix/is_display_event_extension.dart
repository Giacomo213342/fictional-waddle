import 'package:matrix/matrix.dart';

extension IsDisplayEventExtension on Event {
  bool get shouldDisplayEvent =>
      ![
        RelationshipTypes.edit,
        RelationshipTypes.reaction,
      ].contains(relationshipType) &&
      ![EventTypes.Redaction].contains(type);
}
