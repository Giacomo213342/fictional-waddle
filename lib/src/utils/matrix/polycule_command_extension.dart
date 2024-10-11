import 'package:matrix/matrix.dart';

extension PolyculeCommandExtension on Client {
  void registerPolyculeCommands() {
    addCommand('logout', (CommandArgs args) async {
      await logout();
      return '';
    });
    addCommand('roomname', (CommandArgs args) async {
      final name = args.msg.trim();
      await args.room.setName(name);
      return name;
    });
    addCommand('roomdescription', (CommandArgs args) async {
      final name = args.msg.trim();
      await args.room.setDescription(name);
      return name;
    });
  }
}
