# Timeline, Android Conversations, and call lifecycle

## Timeline ownership

- Owner: `_MembershipJoinViewState` owns the reversed `AnimatedList`, its
  `ScrollController`, event keys, fragmented event context, and highlights;
  `ComposeScope` owns text sending.
- Confirmed failures: own-event insertion only marks read when already at
  offset zero and never scrolls there; the latest button is keyed only to a URL
  fragment; reply navigation treats an unbuilt tile exactly like a missing
  event and unnecessarily reloads the route.
- Changes: give `ComposeScopeWidget` an explicit sent callback; derive latest
  affordance visibility from scroll distance; page the current viewport toward
  a loaded target until its lazy tile exists, then use `ensureVisible`. Room
  entry uses no page transition (so the placeholder below it is never exposed),
  paints `Room.lastEvent` while the timeline opens, then reveals at most the
  first twelve cached predecessors with an 80 ms micro-animation.
- Acceptance: text send reaches offset zero; manual movement beyond the
  threshold shows the latest affordance; loaded replies scroll both newer and
  older without route replacement; genuinely unloaded replies retain bounded
  event-context loading and highlight.
- Risks/checks: reversed-axis direction, variable-height events, widget
  disposal during async scrolling, fragmented context return, read markers.
  Widget/pure scroll-decision tests are required; physical gesture validation
  remains required.

## Android Conversations ownership

- Owner: `push_handler.dart` builds `MessagingStyle` notifications; the local
  Android UnifiedPush plugin is attached to both foreground and headless
  Flutter engines and therefore owns native shortcut publication.
- Confirmed failure: background notification handling explicitly disables
  shortcut publication, while the only existing `polycule.shortcuts` handler
  lives in `MainActivity` and cannot exist in a headless engine. Notifications
  therefore have room channels but no guaranteed long-lived shortcut link.
- Changes: register the shortcut method channel in the engine-level local
  UnifiedPush plugin, publish a conversation shortcut with person/category/
  locus/icon, and enable publication in the background event path.
- Acceptance: every complete room message notification links its shortcut ID
  to an existing long-lived conversation shortcut in foreground and cold
  UnifiedPush delivery; room notification taps remain unchanged.
- Risks/checks: duplicate channel handlers, invalid shortcut identifiers,
  Android API compatibility, background engine without Activity. Kotlin build
  plus physical Android notification-settings validation are required.

## Call signaling, Android lifecycle, and post-call back ownership

- Owner: one Matrix `VoIP` per client in `PolyculeCallCoordinator`; the SDK
  owns SDP/ICE and media; the coordinator owns presentation and pending actions;
  `flutter_local_notifications` owns incoming/ongoing Android surfaces; the
  UnifiedPush resolver recognizes call events after decryption.
- Confirmed failures: the SDK's default TURN resolver suppresses endpoint
  failures and caches time-limited credentials forever; call event types fall
  through the generic timeline renderer; `SystemSound` is an in-process alert
  rather than a phone ringtone;
  there is no background incoming or ongoing notification; hiding/ending the
  only overlay leaves no reopen path. The screenshot proves offer/answer/
  negotiate signaling occurs but ICE never reaches connected. The Dart path
  supplies no ICE server when `/voip/turnServer` is empty, unlike the explicit
  `stun:turn.matrix.org` fallback available in matrix-js-sdk, so calls across
  mobile/residential NAT can signal successfully without a reachable pair.
  The fullscreen call was also painted inline above the room and registered a
  second `PopScope` on the room's `ModalRoute`; ending that call could leave
  Android without the room scope as the sole back owner.
- Changes: resolve TURN through the Matrix client with bounded timeout,
  credential TTL refresh, a single in-flight request, and credential-free
  persistent diagnostics. Keep candidate/negotiation transport events hidden,
  but render invite/answer/terminal events with explicit human-readable call
  summaries in the timeline and room preview. Add call-specific incoming/ongoing
  notifications and durable pending actions; separable minimize/show from
  hang-up; call state/ICE timeout
  reporting; a direct-call Matrix STUN fallback plus sanitized description/
  candidate/pair diagnostics; use the current compatible WebRTC implementation
  resolved by CI and configure Android communication audio before media
  acquisition. Incoming calls start as a compact in-app banner. Android owns a
  versioned incoming-call channel configured with the system phone ringtone;
  Flutter never loops `SystemSound.alert` on Android. The call screen is an
  opaque route on the active client branch Navigator, not an inline room
  overlay or an application-root route: system back pops only that route,
  while ending it removes the route and leaves the room's existing declarative
  back scope as Android's active owner. A compact global banner remains
  available for every minimized incoming, connecting, or active call.
- Acceptance: SDP, candidates, negotiation and selection signaling is invisible
  in chat while call lifecycle rows are readable and never expose SDK tokens;
  cold/background invite rings and
  exposes answer/decline; active notification is ongoing and reopens the call;
  minimizing preserves the session; termination clears every call surface;
  ICE connected marks the native notification connected, while timeout/failure
  ends visibly instead of hanging forever. Ending/minimizing a call followed by
  native back returns from the room to its list exactly once.
- Risks/checks: duplicate ringing, expired invites, encrypted call events,
  action arriving before client sync, active-call process lifecycle, relay-only
  TURN, notification permission/full-screen permission, media cleanup. Unit
  tests cover classification, pending-action matching, notification identity,
  and timeout policy; server build and two-device physical validation are
  mandatory.
