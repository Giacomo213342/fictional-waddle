import 'package:matrix/matrix.dart';

extension DatabaseDrafts on DatabaseApi {
  static const _key = 'im.polycule.drafts';

  Future<String?> getRoomDraft(String roomId) async {
    final data = await getAccountData();
    return data[_key]?.content[roomId] as String?;
  }

  Future<void> storeRoomDraft(String roomId, String draft) async {
    final data = await getAccountData();
    final content = data[_key]?.content ?? <String, Object>{};
    if (draft.isEmpty) {
      if (content.containsKey(roomId)) {
        content.remove(roomId);
      }
    } else {
      content[roomId] = draft;
    }
    await storeAccountData(_key, content);
  }
}
