import 'package:flutter/material.dart';

import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/profile_builder.dart';
import '../../widgets/matrix/user_tile/user_tile.dart';
import 'user_page.dart';

class UserView extends StatelessWidget {
  const UserView({super.key, required this.controller});

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ProfileBuilder(
          userId: controller.widget.mxid,
          builder: (context, snapshot) {
            final profile = snapshot.data;
            if (profile == null) {
              return const AsciiProgressIndicator();
            }
            return Card(
              child: UserTile(
                loading: controller.loading,
                profile: profile,
                onDirectChat: controller.startDirectChat,
                onIgnore: controller.toggleIgnore,
                onVerification: controller.startVerification,
              ),
            );
          },
        ),
      ),
    );
  }
}
