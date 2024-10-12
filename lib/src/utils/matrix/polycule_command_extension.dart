import 'package:matrix/matrix.dart';

extension PolyculeCommandExtension on Client {
  void registerPolyculeCommands() {
    addCommand('logout', (args, stdout) async {
      await logout();
      return null;
    });
    addCommand('roomname', (args, stdout) async {
      final room = args.room;
      if (room == null) {
        throw const RoomCommandException();
      }
      final name = args.msg.trim();
      await room.setName(name);
      return null;
    });
    addCommand('roomdescription', (CommandArgs args, stdout) async {
      final room = args.room;
      if (room == null) {
        throw const RoomCommandException();
      }
      final name = args.msg.trim();
      await room.setDescription(name);
      return null;
    });
  }
}
