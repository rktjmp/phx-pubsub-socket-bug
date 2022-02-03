# StickyBug

## Outline

We have a standard LiveView app, and we want to show notifications.

We deliver notifications over a PubSub topic.

We have a standard LiveView setup, with one nested LiveView (`ListenLive`).

`ListenLive` subscribes to the topic on mount (once connected) and then handles
new notifications as they come.

`Notify` (nested in ListenLive for this demo) provides a `.notify` function that
will broadcast a notification on the topic.

`ListenLive` is `sticky` but that does not actually effect the observed behaviour.

## Bugs

There are two bugs observed, see http://localhost:4000/bug/alice for
reproduction instructions.

1) A javascript exception "statics is undefined" in `comprehensionToBuffer` 

2) ListenLive receives broadcasts, updates its socket assigns, but won't re-render those changes.

[ListenLive (& Notify)](https://github.com/rktjmp/phx-pubsub-socket-bug/blob/master/lib/sticky_bug_web/live/listen_live.ex): The "sticky nested liveview" that renders notifications.

[BugLive](https://github.com/rktjmp/phx-pubsub-socket-bug/blob/master/lib/sticky_bug_web/live/bug_live.ex): The bug triggering code in handle_params.

[OtherLive](https://github.com/rktjmp/phx-pubsub-socket-bug/blob/master/lib/sticky_bug_web/live/other_live.ex): just another navigable page.
