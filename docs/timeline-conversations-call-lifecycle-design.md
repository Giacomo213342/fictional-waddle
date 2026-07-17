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

## Call signaling and Android lifecycle ownership

- Owner: one Matrix `VoIP` per client in `PolyculeCallCoordinator`; the SDK
  owns SDP/ICE and media; the coordinator owns presentation and pending actions;
  `flutter_local_notifications` owns incoming/ongoing Android surfaces; the
  UnifiedPush resolver recognizes call events after decryption.
- Confirmed failures: call event types fall through the generic timeline
  renderer; `SystemSound` is an in-process alert rather than a phone ringtone;
  there is no background incoming or ongoing notification; hiding/ending the
  only overlay leaves no reopen path. The screenshot proves offer/answer/
  negotiate signaling occurs but ICE never reaches connected; exact candidate
  failure still needs state/ICE diagnostics and two-device logs.
- Changes: central call-event classifier; suppress signaling rows and message
  notifications; call-specific incoming/ongoing notifications and durable
  pending actions; separable minimize/show from hang-up; call state/ICE timeout
  reporting; use the current compatible WebRTC implementation resolved by CI
  and configure Android communication audio before media acquisition.
- Acceptance: signaling is invisible in chat; cold/background invite rings and
  exposes answer/decline; active notification is ongoing and reopens the call;
  minimizing preserves the session; termination clears every call surface;
  ICE connected marks the native notification connected, while timeout/failure
  ends visibly instead of hanging forever.
- Risks/checks: duplicate ringing, expired invites, encrypted call events,
  action arriving before client sync, active-call process lifecycle, relay-only
  TURN, notification permission/full-screen permission, media cleanup. Unit
  tests cover classification, pending-action matching, notification identity,
  and timeout policy; server build and two-device physical validation are
  mandatory.
