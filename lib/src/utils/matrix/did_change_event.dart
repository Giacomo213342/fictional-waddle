import 'package:matrix/matrix.dart';

extension DidChangeExtension on Event {
  bool didChange(Event oldEvent) =>
      oldEvent.attachmentMxcUrl != attachmentMxcUrl ||
      oldEvent.thumbnailMxcUrl != thumbnailMxcUrl ||
      oldEvent.body != body ||
      oldEvent.status != status;
}
