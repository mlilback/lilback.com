---
title: CKSyncEngine's fetchChanges() Doesn't Always Fetch Changes
date: '2026-10-28 13:00:00'
layout: post
categories:
- Alcove
- Apple
- Programming
tags: [swift, CloudKit, CKSyncEngine, iCloud, Claude Code]
author: mlilback
image:
  path: /images/cksyncengine-fetchchanges.jpg
  alt: "CKSyncEngine's log: my fetchChanges() posts WillFetchChanges and DidFetchChanges in the same millisecond, while the engine's own fetch runs a real database-changes operation."
---

I've done iCloud sync before. In 2012 I spent most of a year on Collabase, a Mac and iPad app that synced its documents first through Dropbox and then through iCloud. A good chunk of that commit log is conflict resolution, merge tests, and deadlocks. CloudKit didn't exist yet.

[Alcove](https://alcoveapp.app) uses `CKSyncEngine`, which is supposed to handle the hard parts for you. Mostly it does. But this bug took a month to pin down, and that was with Claude doing a lot of the digging. Sync is still hard to get right.

This is the short version, so the next person Googling it finds an answer:

A `CKSyncEngine` created from saved state only asks the server for database changes (new or changed zones) after a push, or when the app posts its foreground notification. `fetchChanges()` only fetches zones the engine already thinks have changed. Create the engine after the app is active, with no push arriving, and it never sees what another device wrote.

The symptom on my iPad was `fetchChanges()` "completing" in 0 ms on four launches in a row. The `willFetchChanges` and `didFetchChanges` events landed in the same millisecond, and a library I'd created on the Mac never showed up. Deleting the saved engine state fixed it at once, with a real 3.5 second fetch.

Alcove creates its engine about 5 seconds into launch, because it first waits for `currentUserRecordName()` to see if the iCloud account changed while the app was quit. By then the app is already active, and the notification the engine was listening for is long gone.

My first workaround timed the launch fetch. Anything under 50 ms counted as skipped, so it retried a few times and then threw away the saved state and rebuilt the engine. The data arrived, so it looked like it worked. A month later the journals showed the iPad rebuilding on most launches and downloading 246 records, about 5 seconds, to pick up one changed reading position. The workaround had quietly become the normal path. And the 50 ms test missed about half the skipped fetches anyway, since a busy engine can take longer than that to do nothing.

The engine is listening for `NSApplication.willBecomeActiveNotification` on the Mac and `UIApplication.willEnterForegroundNotification` on iOS. Posting either one yourself triggers the fetch. `didBecomeActive` does nothing on either platform. Neither does `fetchChanges(.init(scope: .zoneIDs([...])))` on a zone I knew had changed. The engine logs "no zone IDs needing to be fetched, not fetching changes" and moves on. I haven't found any of this in Apple's documentation, and the `fetchChanges()` docs read as if it always fetches.

I didn't fix it by posting the notification. [TelemetryDeck](https://telemetrydeck.com)'s SDK observes `willEnterForeground` too, and every post starts a new session timer without invalidating the old one. Faking a system notification is the kind of fix that breaks somebody else's code.

On the Mac, Alcove now creates the engine in `applicationWillFinishLaunching`, before activation, and the real startup adopts it after the account check or throws it away. That means holding the delegate's events until the account check finishes, since CloudKit can start calling back first.

The iPad can't do that, because a cold launch never posts `willEnterForeground`. So Alcove keeps its own `CKServerChangeToken` for the private database and checks it after any launch where the engine reported no database changes:

```swift
let result = try await database.databaseChanges(since: token)
// result.modifications, result.deletions, result.changeToken, result.moreComing
```

If zones changed, it fetches just those with `recordZoneChanges`, using a token of its own per zone, and applies them the same way the engine would. The engine fetches the same records again at its next real fetch, which is harmless. A page turned on the Mac now costs the iPad one record instead of 246.

[Vinit Kumar posted about the same behavior](https://fosstodon.org/@vinitkme/117495802479863550) on October 24th, while building sync for Gotcha RSS Feed, and also ended up reading the zone directly on launch. He blamed a missed push. It isn't only the push, though. The foreground notification works too, as long as the engine exists before it's posted.

I filed FB25319128 with a sysdiagnose. In it my launch `fetchChanges()` call posts will and did in the same millisecond, my database check finds the changed zone 7 ms later, and the push that would have rescued it arrives 25 ms after that. I also filed the [TelemetryDeck bug](https://github.com/TelemetryDeck/SwiftSDK/issues/303).

None of this involved a debugger. It came from a structured sync journal on every device, pulled off the iPad with `devicectl`, and a handful of probe builds that lived for an afternoon.
