import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class RoomState extends StatelessWidget {
  const RoomState({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: FutureBuilder<String>(
        future: event.calcLocalizedBody(
          const MatrixDefaultLocalizations(),
        ),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ??
                event.calcLocalizedBodyFallback(
                  const MatrixDefaultLocalizations(),
                ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
