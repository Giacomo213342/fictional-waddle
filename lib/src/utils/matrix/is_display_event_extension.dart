import 'package:matrix/matrix.dart';

extension IsDisplayEventExtension on Event {
  bool get isDisplayEvent => ![
        RelationshipTypes.edit,
        RelationshipTypes.reaction,
      ].contains(relationshipType);
}
