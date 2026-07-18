import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/voip/polycule_call_coordinator.dart';

class GroupCallView extends StatefulWidget {
  const GroupCallView({
    super.key,
    required this.activeCall,
    required this.onMinimize,
  });

  final ActivePolyculeGroupCall activeCall;
  final VoidCallback onMinimize;

  @override
  State<GroupCallView> createState() => _GroupCallViewState();
}

class _GroupCallViewState extends State<GroupCallView> {
  final Map<WrappedMediaStream, webrtc.RTCVideoRenderer> _renderers = {};
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _syncingRenderers = false;
  bool _resyncRenderers = false;
  bool _busy = false;
  bool _speakerOn = true;

  GroupCallSession get call => widget.activeCall.session;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      call.onGroupCallEvent.stream.listen((_) => _handleCallUpdate()),
      call.onGroupCallState.stream.listen((_) => _handleCallUpdate()),
    ]);
    unawaited(_synchronizeRenderers());
  }

  void _handleCallUpdate() {
    unawaited(_synchronizeRenderers());
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _synchronizeRenderers() async {
    if (_syncingRenderers) {
      _resyncRenderers = true;
      return;
    }
    _syncingRenderers = true;
    try {
      do {
        _resyncRenderers = false;
        final streams = call.backend.userMediaStreams
            .where((stream) => stream.stream != null)
            .toSet();
        final removed = _renderers.keys
            .where((stream) => !streams.contains(stream))
            .toList();
        for (final stream in removed) {
          final renderer = _renderers.remove(stream);
          if (renderer != null) {
            renderer.srcObject = null;
            await renderer.dispose();
          }
        }
        for (final stream in streams) {
          if (_renderers.containsKey(stream)) {
            final renderer = _renderers[stream]!;
            if (!identical(renderer.srcObject, stream.stream)) {
              renderer.srcObject = stream.stream;
            }
            continue;
          }
          final renderer = webrtc.RTCVideoRenderer();
          await renderer.initialize();
          if (!mounted || !call.backend.userMediaStreams.contains(stream)) {
            await renderer.dispose();
            continue;
          }
          renderer.srcObject = stream.stream;
          _renderers[stream] = renderer;
        }
      } while (_resyncRenderers && mounted);
    } finally {
      _syncingRenderers = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    for (final renderer in _renderers.values) {
      renderer.srcObject = null;
      unawaited(renderer.dispose());
    }
    _renderers.clear();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
    } catch (error, stackTrace) {
      Logs().w('[VOIP] Group call action failed.', error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final streams = call.backend.userMediaStreams;
    final participantIds = call.participants.map((p) => p.userId).toSet()
      ..addAll(
        call.backend.userMediaStreams
            .map((stream) => stream.participant.userId),
      );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _GroupCallHeader(
              roomName: _groupRoomName(call.room),
              participantCount: participantIds.length,
              onMinimize: widget.onMinimize,
            ),
            Expanded(
              child: streams.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _GroupMediaGrid(streams: streams, renderers: _renderers),
            ),
            if (widget.activeCall.blockingError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  widget.activeCall.blockingError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            _GroupCallControls(
              busy: _busy,
              microphoneMuted: call.backend.isMicrophoneMuted,
              cameraMuted: call.backend.isLocalVideoMuted,
              speakerOn: _speakerOn,
              onToggleMicrophone: () => _run(
                () => call.backend.setDeviceMuted(
                  call,
                  !call.backend.isMicrophoneMuted,
                  MediaInputKind.audioinput,
                ),
              ),
              onToggleCamera: () => _run(
                () => call.backend.setDeviceMuted(
                  call,
                  !call.backend.isLocalVideoMuted,
                  MediaInputKind.videoinput,
                ),
              ),
              onSwitchCamera: () => _run(_switchCamera),
              onToggleSpeaker: () => _run(_toggleSpeaker),
              onLeave: () => _run(call.leave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    final tracks = call.backend.localUserMediaStream?.stream?.getVideoTracks();
    if (tracks == null || tracks.isEmpty) {
      return;
    }
    await webrtc.Helper.switchCamera(tracks.first);
  }

  Future<void> _toggleSpeaker() async {
    final enabled = !_speakerOn;
    await webrtc.Helper.setSpeakerphoneOn(enabled);
    if (mounted) {
      setState(() => _speakerOn = enabled);
    }
  }
}

class _GroupCallHeader extends StatelessWidget {
  const _GroupCallHeader({
    required this.roomName,
    required this.participantCount,
    required this.onMinimize,
  });

  final String roomName;
  final int participantCount;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
        child: Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Minimize call',
              onPressed: onMinimize,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(roomName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    '$participantCount participant'
                    '${participantCount == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GroupMediaGrid extends StatelessWidget {
  const _GroupMediaGrid({required this.streams, required this.renderers});

  final List<WrappedMediaStream> streams;
  final Map<WrappedMediaStream, webrtc.RTCVideoRenderer> renderers;

  @override
  Widget build(BuildContext context) {
    final columns = streams.length <= 1
        ? 1
        : streams.length <= 4
            ? 2
            : 3;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final stream = streams[index];
        return _GroupParticipantTile(
          stream: stream,
          renderer: renderers[stream],
        );
      },
    );
  }
}

class _GroupParticipantTile extends StatelessWidget {
  const _GroupParticipantTile({required this.stream, required this.renderer});

  final WrappedMediaStream stream;
  final webrtc.RTCVideoRenderer? renderer;

  @override
  Widget build(BuildContext context) {
    final name = stream.displayName ?? stream.participant.userId;
    final videoVisible = renderer != null && !stream.isVideoMuted();
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (videoVisible)
            webrtc.RTCVideoView(
              renderer!,
              mirror: stream.isLocal(),
              objectFit:
                  webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Center(
              child: CircleAvatar(
                radius: 34,
                child: Text(name.isEmpty ? '?' : name.characters.first),
              ),
            ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 6,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stream.isLocal() ? '$name · you' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(shadows: [Shadow(blurRadius: 4)]),
                  ),
                ),
                if (stream.isAudioMuted()) const Icon(Icons.mic_off, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCallControls extends StatelessWidget {
  const _GroupCallControls({
    required this.busy,
    required this.microphoneMuted,
    required this.cameraMuted,
    required this.speakerOn,
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onToggleSpeaker,
    required this.onLeave,
  });

  final bool busy;
  final bool microphoneMuted;
  final bool cameraMuted;
  final bool speakerOn;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _GroupControlButton(
              tooltip: microphoneMuted ? 'Unmute' : 'Mute',
              icon: microphoneMuted ? Icons.mic_off : Icons.mic,
              onPressed: busy ? null : onToggleMicrophone,
            ),
            _GroupControlButton(
              tooltip: speakerOn ? 'Use earpiece' : 'Use speaker',
              icon: speakerOn ? Icons.volume_up : Icons.hearing,
              onPressed: busy ? null : onToggleSpeaker,
            ),
            _GroupControlButton(
              tooltip: cameraMuted ? 'Enable camera' : 'Disable camera',
              icon: cameraMuted ? Icons.videocam_off : Icons.videocam,
              onPressed: busy ? null : onToggleCamera,
            ),
            _GroupControlButton(
              tooltip: 'Switch camera',
              icon: Icons.cameraswitch,
              onPressed: busy ? null : onSwitchCamera,
            ),
            _GroupControlButton(
              tooltip: 'Leave call',
              icon: Icons.call_end,
              color: Theme.of(context).colorScheme.error,
              onPressed: busy ? null : onLeave,
            ),
          ],
        ),
      );
}

class _GroupControlButton extends StatelessWidget {
  const _GroupControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        style: color == null
            ? null
            : IconButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
        icon: Icon(icon),
      );
}

String _groupRoomName(Room room) {
  final name = room.name.trim();
  if (name.isNotEmpty) {
    return name;
  }
  final alias = room.canonicalAlias.trim();
  return alias.isEmpty ? 'Group call' : alias;
}
