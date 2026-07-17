# Matrix one-to-one calls

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

WebRTC media is ICE/DTLS/SRTP and cannot be sent through the app's HTTP SOCKS5
client. When "proxy calls" is enabled, the delegate sets
`iceTransportPolicy: relay`, which prevents direct host/STUN candidates and
uses only the homeserver-provided TURN relay. TURN credential retrieval and
Matrix signaling still traverse the configured SOCKS5 HTTP client. If no TURN
server is available, call setup fails visibly instead of leaking to a direct
path.

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
- Relay-only preference persists. Enabled calls never fall back to direct ICE,
  and fail clearly when TURN is missing.

## Regression and validation

- Focused tests cover relay configuration/validation, call eligibility, and
  network setting copy/equality behavior.
- Format touched Dart only, run diff check, focused/full tests and analyzer,
  then a signed ARM64 GitHub build before main-branch publication.
- Physical Android validation remains required with two Matrix accounts for
  microphone/camera permissions, audio routing/Bluetooth, both call directions,
  remote hang-up, camera switching, relay-only ICE, background incoming calls,
  and Android native back.
