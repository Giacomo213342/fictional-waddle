import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../scopes/matrix_scope.dart';
import '../tab.dart';

class DraggableClient extends StatelessWidget {
  const DraggableClient({super.key});

  @override
  Widget build(BuildContext context) {
    // the tab will be on an overlay while dragging
    final scope = MatrixScope.captureAll(context);
    final client = scope.client;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LongPressDraggable<Client>(
        data: client,
        feedback: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: MatrixScope(
            scope: scope,
            child: const ClientTab(),
          ),
        ),
        child: const Center(child: ClientTab()),
      ),
    );
  }
}
