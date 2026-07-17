import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/voip/polycule_call_coordinator.dart';
import '../avatar_builder/user_avatar.dart';

class CallView extends StatefulWidget {
  const CallView({
    super.key,
    required this.activeCall,
    required this.onMinimize,
  });

  final ActivePolyculeCall activeCall;
  final VoidCallback onMinimize;

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  final _remoteRenderer = webrtc.RTCVideoRenderer();
  final _localRenderer = webrtc.RTCVideoRenderer();
  final List<StreamSubscription<dynamic>> _callSubscriptions = [];
  bool _renderersReady = false;
  bool _busy = false;
  bool _speakerOn = false;

  CallSession get call => widget.activeCall.session;

  @override
  void initState() {
    super.initState();
    _speakerOn = call.type == CallType.kVideo;
    void handleUpdate(_) {
      if (!mounted) {
        return;
      }
      _syncRenderers();
      setState(() {});
    }

    _callSubscriptions.addAll([
      call.onCallStateChanged.stream.listen(handleUpdate),
      call.onCallEventChanged.stream.listen(handleUpdate),
      call.onCallStreamsChanged.stream.listen(handleUpdate),
    ]);
    unawaited(_initializeRenderers());
  }

  Future<void> _initializeRenderers() async {
    await Future.wait([
      _remoteRenderer.initialize(),
      _localRenderer.initialize(),
    ]);
    if (!mounted) {
      return;
    }
    _renderersReady = true;
    _syncRenderers();
    setState(() {});
  }

  void _syncRenderers() {
    if (!_renderersReady) {
      return;
    }
    final remote = call.remoteUserMediaStream?.stream;
    final local = call.localUserMediaStream?.stream;
    if (!identical(_remoteRenderer.srcObject, remote)) {
      _remoteRenderer.srcObject = remote;
    }
    if (!identical(_localRenderer.srcObject, local)) {
      _localRenderer.srcObject = local;
    }
  }

  @override
  void dispose() {
    for (final subscription in _callSubscriptions) {
      unawaited(subscription.cancel());
    }
    if (_renderersReady) {
      _remoteRenderer.srcObject = null;
      _localRenderer.srcObject = null;
    }
    unawaited(_remoteRenderer.dispose());
    unawaited(_localRenderer.dispose());
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
      Logs().w('1:1 call action failed.', error, stackTrace);
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

  Future<void> _hangup() => _run(
        () => call.state == CallState.kRinging && !call.answeredByUs
            ? call.reject(reason: CallErrorCode.userHangup)
            : call.hangup(reason: CallErrorCode.userHangup),
      );

  @override
  Widget build(BuildContext context) {
    final isIncoming = call.direction == CallDirection.kIncoming &&
        call.state == CallState.kRinging &&
        !call.answeredByUs;
    final isVideo = call.type == CallType.kVideo;
    final remoteVideoVisible = isVideo &&
        call.remoteUserMediaStream != null &&
        !(call.remoteUserMediaStream?.isVideoMuted() ?? true);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CallBackdrop(
            call: call,
            remoteRenderer: _remoteRenderer,
            showVideo: remoteVideoVisible && _renderersReady,
          ),
          if (isVideo && _renderersReady)
            Positioned(
              right: 16,
              top: MediaQuery.paddingOf(context).top + 16,
              width: 112,
              height: 160,
              child: Material(
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: webrtc.RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit:
                      webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton.filledTonal(
                      tooltip: 'Minimize call',
                      onPressed: widget.onMinimize,
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ),
                const Spacer(),
                _CallControls(
                  call: call,
                  busy: _busy,
                  incoming: isIncoming,
                  blockingError: widget.activeCall.blockingError,
                  connectionStatus: widget.activeCall.connectionStatus,
                  speakerOn: _speakerOn,
                  onAnswer: () => _run(call.answer),
                  onHangup: _hangup,
                  onToggleMicrophone: () => _run(
                    () => call.setMicrophoneMuted(!call.isMicrophoneMuted),
                  ),
                  onToggleCamera: isVideo
                      ? () => _run(
                            () => call.setLocalVideoMuted(
                              !call.isLocalVideoMuted,
                            ),
                          )
                      : null,
                  onSwitchCamera: isVideo ? _switchCamera : null,
                  onToggleSpeaker: _toggleSpeaker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchCamera() => _run(() async {
        final tracks = call.localUserMediaStream?.stream?.getVideoTracks();
        if (tracks == null || tracks.isEmpty) {
          return;
        }
        await webrtc.Helper.switchCamera(tracks.first);
      });

  Future<void> _toggleSpeaker() => _run(() async {
        final tracks = call.localUserMediaStream?.stream?.getAudioTracks();
        if (tracks == null || tracks.isEmpty) {
          return;
        }
        final enabled = !_speakerOn;
        await webrtc.Helper.setSpeakerphoneOn(enabled);
        if (mounted) {
          setState(() => _speakerOn = enabled);
        }
      });
}

class _CallBackdrop extends StatelessWidget {
  const _CallBackdrop({
    required this.call,
    required this.remoteRenderer,
    required this.showVideo,
  });

  final CallSession call;
  final webrtc.RTCVideoRenderer remoteRenderer;
  final bool showVideo;

  @override
  Widget build(BuildContext context) {
    if (showVideo) {
      return webrtc.RTCVideoView(
        remoteRenderer,
        objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    }
    final remote = call.remoteUser;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remote != null)
              UserAvatar(user: remote, client: call.client, dimension: 112),
            const SizedBox(height: 20),
            Text(
              remote?.calcDisplayname() ?? call.remoteUserId ?? 'Unknown user',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_callStateLabel(call)),
          ],
        ),
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.call,
    required this.busy,
    required this.incoming,
    required this.blockingError,
    required this.connectionStatus,
    required this.speakerOn,
    required this.onAnswer,
    required this.onHangup,
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onToggleSpeaker,
  });

  final CallSession call;
  final bool busy;
  final bool incoming;
  final String? blockingError;
  final String? connectionStatus;
  final bool speakerOn;
  final VoidCallback onAnswer;
  final VoidCallback onHangup;
  final VoidCallback onToggleMicrophone;
  final VoidCallback? onToggleCamera;
  final VoidCallback? onSwitchCamera;
  final VoidCallback onToggleSpeaker;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(240),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (blockingError != null) ...[
                  Text(
                    blockingError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                if (!incoming && connectionStatus != null) ...[
                  Text(
                    connectionStatus!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (incoming)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundCallButton(
                        tooltip: 'Decline',
                        background: Theme.of(context).colorScheme.error,
                        onPressed: busy ? null : onHangup,
                        icon: Icons.call_end,
                      ),
                      _RoundCallButton(
                        tooltip: 'Answer',
                        background: Colors.green.shade700,
                        onPressed:
                            busy || blockingError != null ? null : onAnswer,
                        icon: call.type == CallType.kVideo
                            ? Icons.videocam
                            : Icons.call,
                      ),
                    ],
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _RoundCallButton(
                        tooltip: call.isMicrophoneMuted ? 'Unmute' : 'Mute',
                        onPressed: busy ? null : onToggleMicrophone,
                        icon:
                            call.isMicrophoneMuted ? Icons.mic_off : Icons.mic,
                      ),
                      _RoundCallButton(
                        tooltip: speakerOn ? 'Use earpiece' : 'Use speaker',
                        onPressed: busy ? null : onToggleSpeaker,
                        icon: speakerOn ? Icons.volume_up : Icons.hearing,
                      ),
                      if (onToggleCamera != null)
                        _RoundCallButton(
                          tooltip: call.isLocalVideoMuted
                              ? 'Enable camera'
                              : 'Disable camera',
                          onPressed: busy ? null : onToggleCamera,
                          icon: call.isLocalVideoMuted
                              ? Icons.videocam_off
                              : Icons.videocam,
                        ),
                      if (onSwitchCamera != null)
                        _RoundCallButton(
                          tooltip: 'Switch camera',
                          onPressed: busy ? null : onSwitchCamera,
                          icon: Icons.cameraswitch,
                        ),
                      _RoundCallButton(
                        tooltip: 'Hang up',
                        background: Theme.of(context).colorScheme.error,
                        onPressed: busy ? null : onHangup,
                        icon: Icons.call_end,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}

class _RoundCallButton extends StatelessWidget {
  const _RoundCallButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.background,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? background;

  @override
  Widget build(BuildContext context) => IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: background),
        icon: Icon(icon),
      );
}

String _callStateLabel(CallSession call) => switch (call.state) {
      CallState.kFledgling ||
      CallState.kWaitLocalMedia ||
      CallState.kCreateOffer ||
      CallState.kCreateAnswer =>
        'Preparing call…',
      CallState.kInviteSent => 'Ringing…',
      CallState.kConnecting => 'Connecting…',
      CallState.kConnected => 'Connected',
      CallState.kRinging => 'Incoming call',
      CallState.kEnding => 'Ending call…',
      CallState.kEnded => 'Call ended',
    };
