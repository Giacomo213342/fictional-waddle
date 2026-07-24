import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preview captures a separate description for each image', () {
    final preview = File(
      'lib/src/widgets/file_preview_dialog/file_preview_dialog_view.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/src/widgets/file_preview_dialog/file_preview_dialog.dart',
    ).readAsStringSync();
    final selector =
        File('lib/src/utils/file_selector.dart').readAsStringSync();

    expect(preview, contains("labelText: 'Image description'"));
    expect(preview, contains('isImageXFile(file)'));
    expect(controller, contains('Map<XFile, TextEditingController>'));
    expect(controller, contains('descriptions: {'));
    expect(selector, contains('description: descriptions[file]'));
  });

  test('image descriptions are sent as body while filename is preserved', () {
    final sender = File(
      'lib/src/pages/room/components/compose/send_file_scope.dart',
    ).readAsStringSync();
    final queue = File(
      'lib/src/utils/matrix/media_upload_queue.dart',
    ).readAsStringSync();

    expect(sender, contains("'body': description"));
    expect(sender, contains("'filename': tuple.file.name"));
    expect(sender, contains('tuple.file is MatrixImageFile'));
    expect(queue, contains("'extraContent': extraContent"));
  });

  test('received descriptions are visible and exposed to accessibility', () {
    final content = File(
      'lib/src/pages/room/components/event/m_room_message_content.dart',
    ).readAsStringSync();
    final image = File(
      'lib/src/pages/room/components/event/m_room_message/m_image.dart',
    ).readAsStringSync();

    expect(content, contains('imageDescriptionForEvent(event)'));
    expect(content, contains('Text(description)'));
    expect(image, contains("event.content['filename']"));
    expect(image, contains('body == filename.trim()'));
    expect(image, contains('Semantics('));
    expect(image, contains('label: description ?? event.body'));
  });
}
