# Polycule UnifiedPush Android backport

This directory vendors `unifiedpush_android` 3.4.0 from pub.dev.

Polycule clears the plugin's static event flow when its FlutterEngine detaches.
Without that reset, a cached Android process can keep a stale flow after the UI
engine is destroyed. A later UnifiedPush service start then skips creation of a
headless engine and delivers the event to a flow with no collector.

The identity check in `Plugin.onDetachedFromEngine` prevents an older plugin
instance from clearing a newer instance's flow. This backports the event
reinitialization behavior released upstream in 3.4.1 without requiring package
resolution or downloads during local development.
