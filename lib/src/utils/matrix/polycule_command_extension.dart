import 'package:matrix/matrix.dart';

extension PolyculeCommandExtension on Client {
  void registerPolyculeCommands() {
    addCommand('logout', (args, stdout) async {
      await logout();
      return null;
    });
    addCommand('upgraderoom', (args, stdout) async {
      final room = args.room;
      if (room == null) {
        throw const RoomCommandException();
      }
      final versionString = args.msg.trim().split(' ').firstOrNull;
      if (versionString == null) {
        throw const CommandException('One argument expected.');
      }
      final version = int.tryParse(versionString);
      if (version == null) {
        throw const CommandException('Version must be an integer.');
      }
      final roomId = await room.client.upgradeRoom(room.id, version.toString());
      stdout?.write(DefaultCommandOutput(rooms: [roomId]).toString());
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
