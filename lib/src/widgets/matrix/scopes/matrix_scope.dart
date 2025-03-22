import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import 'client_scope.dart';
import 'device_scope.dart';
import 'event_scope.dart';
import 'matrix_identifier_scope.dart';
import 'room_scope.dart';
import 'sas_scope.dart';
import 'session_scope.dart';
import 'timeline_scope.dart';

class ScopeCapture {
  const ScopeCapture({
    required this.client,
    this.room,
    this.device,
    this.session,
    this.timeline,
    this.event,
    this.verification,
    this.identifier,
  });

  final Client client;
  final Room? room;
  final Device? device;
  final DeviceKeys? session;
  final TimelineScope? timeline;
  final EventScope? event;
  final KeyVerification? verification;
  final MatrixIdentifierStringExtensionResults? identifier;
}

class MatrixScope extends StatelessWidget {
  const MatrixScope({super.key, required this.scope, required this.child});

  static ScopeCapture captureAll(
    BuildContext context,
  ) =>
      ScopeCapture(
        client:
            context.dependOnInheritedWidgetOfExactType<ClientScope>()!.client,
        room: context.dependOnInheritedWidgetOfExactType<RoomScope>()?.room,
        device:
            context.dependOnInheritedWidgetOfExactType<DeviceScope>()?.device,
        timeline: context.dependOnInheritedWidgetOfExactType<TimelineScope>(),
        event: context.dependOnInheritedWidgetOfExactType<EventScope>(),
        verification: context
            .dependOnInheritedWidgetOfExactType<SasScope>()
            ?.verification,
        identifier: context
            .dependOnInheritedWidgetOfExactType<MatrixIdentifierScope>()
            ?.identifier,
      );

  final ScopeCapture scope;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = this.child;
    final scope = this.scope;

    final event = scope.event;
    if (event != null) {
      child = EventScope(
        event: event.event,
        /*previousEvent: event.previousEvent,
        nextEvent: event.nextEvent,*/
        child: child,
      );
    }

    final timeline = scope.timeline;
    if (timeline != null) {
      child = TimelineScope(
        timeline: timeline.timeline,
        eventChangeStream: timeline.eventChangeStream,
        child: child,
      );
    }

    final verification = scope.verification;
    if (verification != null) {
      child = SasScope(
        verification: verification,
        child: child,
      );
    }

    final identifier = scope.identifier;
    if (identifier != null) {
      child = MatrixIdentifierScope(
        identifier: identifier,
        child: child,
      );
    }

    final device = scope.device;
    if (device != null) {
      child = DeviceScope(
        device: device,
        child: child,
      );
    }

    final session = scope.session;
    if (session != null) {
      child = SessionScope(
        session: session,
        child: child,
      );
    }

    final room = scope.room;
    if (room != null) {
      child = RoomScope(
        room: room,
        child: child,
      );
    }

    final client = scope.client;
    return ClientScope(
      client: client,
      child: child,
    );
  }
}
