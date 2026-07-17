# Matrix one-to-one calls

## Startup integration correction

- State owner: `ClientManager` owns the call coordinator; `SettingsManager`
  owns the relay preference; the top-level `ClientManagerRoute` owns the
  application navigation surface on which an active call is shown.
- Confirmed failure: the first implementation asked `ClientManager` for a
  `SettingsManager` that was below it in the widget tree, so the release build
  threw before rendering the router and Android displayed a grey screen. The
  call `Stack` was also above `MaterialApp`, where it had no `Directionality`,
  theme, media query, or modal route for back handling.
- Files/APIs: reorder `SettingsBuilder` and `ClientManagerRoot` in
  `polycule.dart`; keep coordinator setup in `ClientManager`; mount
  `CallOverlayHost` inside `ClientManagerRoute`.
- Acceptance: a cold launch renders the existing router without an exception;
  an active call inherits the app theme and current route; with no active call,
  the host is layout-transparent and does not change navigation or back state.
- Regression risks/checks: ensure one settings instance is shared by the HTTP
  client, clients, and UI; widget-test startup ownership and the inactive call
  host; analyze the touched modules and complete the signed ARM64 server build.
- Physical Android testing: required for the repaired cold launch and for
  incoming/in-call presentation and native back during a call.

## Ownership and confirmed integration path

- `ClientManager` owns Matrix client lifetimes, so it also owns one
  `PolyculeVoipClient`/Matrix `VoIP` instance per client. Room widgets only ask
  that coordinator to start a call; they never subscribe to signaling.
- Matrix SDK `VoIP` already consumes `Client.onCallEvents`, fetches homeserver
  TURN credentials, emits/consumes `m.call.*`, and owns `CallSession` state and
  media streams. The missing layer is a concrete `WebRTCDelegate` backed by
  `flutter_webrtc` plus application UI.
- A single coordinator-level active-call notifier drives a full-window overlay
  above the existing router. This leaves room/list navigator ownership and the
  repaired Android back stack untouched.
- `SettingsManager.network` owns the SOCKS and relay-only preference. Matrix
  signaling already uses the configured Polycule HTTP client. The delegate
  reads the current setting when each peer connection is created.

## Proxy semantics

`flutter_webrtc` does not inherit the app's HTTP connection factory. Merely
setting `iceTransportPolicy: relay` still opens TURN directly and therefore
does not satisfy the SOCKS5 setting. When "proxy calls" is enabled, Polycule
now binds an ephemeral TCP listener on IPv4 loopback and rewrites each
homeserver `turn:...?transport=tcp` URI to that listener. Every accepted TURN
connection is forwarded through the configured, optionally authenticated,
SOCKS5 proxy to the original hostname and port. The delegate simultaneously
sets relay-only ICE, so no host, STUN, UDP TURN, or direct TCP TURN path can
bypass the tunnel. The listener and every accepted socket are owned by the
client's WebRTC delegate and closed when that delegate is disposed.

TURN credential retrieval and Matrix signaling continue to use the normal
Polycule SOCKS5 HTTP client. If the homeserver does not provide plaintext
TURN/TCP, call setup fails visibly instead of silently leaking or hanging.
Outside proxy-call mode, a public STUN fallback is added only when the
homeserver list contains no STUN URI; homeserver TURN entries are retained.

## Files and APIs

- Add `flutter_webrtc` and Android audio/video/Bluetooth permissions.
- Extend `NetworkState` and `SettingsInterface` with a persisted
  `proxyOneToOneCalls` value and expose it in Network settings.
- Add a Matrix call coordinator and a concrete `WebRTCDelegate` under
  `lib/src/utils/matrix/voip/`.
- Add the incoming/outgoing/in-call overlay under
  `lib/src/widgets/matrix/call/`.
- Add direct-room audio/video actions to `RoomView`.

## Acceptance criteria

- A joined direct room can start either a voice or video `m.call.*` session to
  its remote MXID; non-direct rooms do not show call actions.
- Incoming calls show caller identity and answer/reject controls everywhere in
  the signed-in UI. Answered/outgoing calls show state, hang-up, mute, and for
  video: remote/local video, camera mute, and camera switch.
- System back on active call requests hang-up and returns to the unchanged
  underlying route; closing the call cannot pop the room/list navigator.
- Ending, rejecting, failing, or remotely ending a call removes the overlay and
  releases renderers/media through the SDK cleanup path.
- Relay-only preference persists. Enabled calls tunnel TURN/TCP through SOCKS5,
  never fall back to direct ICE, and fail clearly when a proxyable TURN route
  is missing.

## Regression and validation

- Focused tests cover relay configuration/validation, authenticated SOCKS5
  byte forwarding and teardown, call eligibility, and network setting
  copy/equality behavior.
- Format touched Dart only, run diff check, focused/full tests and analyzer,
  then a signed ARM64 GitHub build before main-branch publication.
- Physical Android validation remains required with two Matrix accounts for
  microphone/camera permissions, audio routing/Bluetooth, both call directions,
  remote hang-up, camera switching, relay-only ICE, background incoming calls,
  and Android native back.
