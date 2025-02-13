import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'client_scope.dart';
import 'device_scope.dart';
import 'event_scope.dart';
import 'room_scope.dart';
import 'timeline_scope.dart';

class MatrixScope extends StatelessWidget {
  const MatrixScope({super.key, required this.scope, required this.child});

  static (Client, Room?, Device?, TimelineScope?, EventScope?) captureAll(
    BuildContext context,
  ) =>
      (
        context.dependOnInheritedWidgetOfExactType<ClientScope>()!.client,
        context.dependOnInheritedWidgetOfExactType<RoomScope>()?.room,
        context.dependOnInheritedWidgetOfExactType<DeviceScope>()?.device,
        context.dependOnInheritedWidgetOfExactType<TimelineScope>(),
        context.dependOnInheritedWidgetOfExactType<EventScope>(),
      );

  final (Client, Room?, Device?, TimelineScope?, EventScope?) scope;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = this.child;
    final scope = this.scope;

    final event = scope.$5?.event;
    if (event != null) {
      child = EventScope(
        event: event,
        /*previousEvent: scope.$4?.previousEvent,
        nextEvent: scope.$4?.nextEvent,*/
        child: child,
      );
    }

    final timeline = scope.$4;
    if (timeline != null) {
      child = TimelineScope(
        timeline: timeline.timeline,
        eventChangeStream: timeline.eventChangeStream,
        child: child,
      );
    }

    final device = scope.$3;
    if (device != null) {
      child = DeviceScope(
        device: device,
        child: child,
      );
    }

    final room = scope.$2;
    if (room != null) {
      child = RoomScope(
        room: room,
        child: child,
      );
    }

    final client = scope.$1;
    return ClientScope(
      client: client,
      child: child,
    );
  }
}
