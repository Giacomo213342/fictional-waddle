import 'package:flutter/material.dart';

import 'room_list_view.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});
  static const routeName = '/rooms';

  @override
  State<RoomListPage> createState() => RoomListController();
}

class RoomListController extends State<RoomListPage> {
  @override
  Widget build(BuildContext context) => RoomListView(this);
}
