import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class ClientBackButton extends StatelessWidget {
  const ClientBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            return Navigator.of(context).pop();
          }
          final path = GoRouterState.of(context).uri.path;
          if (path.length == 1) {
            return;
          }
          context.pushReplacement(
            path.substring(0, path.lastIndexOf('/')),
          );
        },
      ),
    );
  }
}
