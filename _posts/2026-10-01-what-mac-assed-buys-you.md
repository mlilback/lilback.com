---
title: What Mac-assed buys you
date: '2026-10-01 11:30:00'
layout: post
categories:
- Alcove
- Programming
- Apple
tags: [AppKit, SwiftUI, macOS, Calibre, undo]
author: mlilback
image:
  path: /images/alcove-calibre-import-card.jpg
  alt: Alcove's Calibre import finishing, with the imported library behind it
---

I've been writing Mac apps since classic Mac OS (a version of Hearts written in Think C on a Mac Plus in 1993), so when Brent Simmons explained "[Mac-assed Mac app](https://inessential.com/2020/03/19/proxyman.html)" in 2020 I didn't need the explanation. He got the phrase from Collin Donnell: Mac apps that are unapologetically Mac apps, platform-specific, not trying to wow us with custom UI that isn't Mac-like. [John Gruber](https://daringfireball.net/linked/2020/03/20/mac-assed-mac-apps) nailed why it beats "native". Slack is native. It is not a Mac-assed Mac app.

I love that definition. I don't love what's happened to it since.

The phrase has been stretched to cover SwiftUI apps. There's a widely shared guide for AI coding agents that defines a Mac-assed app and then says to build it in SwiftUI by default. Paulo Andrade [tried exactly that](https://pfandrade.me/blog/mac-assed-swiftui-app/) and his verdict was "we're not there yet." Gruber then [watched Journal lose a sentence to Undo](https://daringfireball.net/2026/06/swiftui_only_makes_it_easy_to_develop_bad_apps). The Mac has had undo right since before NeXT took over Apple [*sic*]. So no, I don't count SwiftUI apps. [Alcove]({% post_url 2026-05-17-introducing-alcove %}), my ebook library manager (currently in [Alpha](https://alcoveapp.app/beta) testing), is AppKit on the Mac, and that's a rule, not a preference.

What that buys is mostly stuff nobody notices. Every command is in the menu bar, and nearly every menu command has an AppleScript verb. Return activates the default button and Escape cancels, in every sheet. ⌘↓ opens a book, like Finder.

The Calibre importer is a good example, because it already worked and I still spent over half a day refining it (with Claude's help).

The first version wrote straight to the database. Import 300 books, choose Undo, and Undo skipped right past them. Worse, nothing it imported was ever synced to iCloud, and nobody noticed. Now the entire import is one Undo, and it syncs.

Then series. Calibre often has no series for a book, so Alcove pulls one from the title. "Allegiant (Divergent Trilogy, Book 3)" is easy. I ran it against my own Calibre library, 305 books, and it was humbling. "Books 1, 2, and 3" is a box set, not a series named "Books 1, 2, and". "Identity Crisis #1 (of 7)" is issue 1. A four-digit number in parentheses is a year, not book 2009. Calibre's file names are useless here because Calibre truncates them.

Alcove keeps deleted tags and series around so sync and undo work. If you had deleted a tag that Calibre also had, the import died halfway through a book. Now it revives the deleted one.

The sheet itself was the last piece. Before: four books it can't import, a scroller for no reason, and truncated reasons.

![The import sheet before, with a stray scroller and truncated failure reasons](/images/alcove-calibre-import-before.jpg)

After:

![The same sheet after, with no scroller and the full reasons visible](/images/alcove-calibre-import-after.jpg)

And the finished state didn't exist. The counts were written into a label that was hidden, so nothing showed. Now it ends on a result and one Done button, which answers Return and Escape both.

![The finished import, reading 301 books imported, with one Done button](/images/alcove-calibre-import-done.jpg)

(Look at the sidebar behind it -- that library was imported before I fixed the parser. Yes, there's a series called "Books 1, 2, and".)

While I was in there, ⌘⌫ started deleting without a confirmation, like Move to Trash in Finder. It's one Undo, so asking first is just friction. Plain Delete still asks.

Sweating these little details is, to me, what defines a Mac-assed app.

---

*When I get a chance, I think I'm going to create a public GitHub repo with some of my design documents, [ADRs](https://adr.github.io), scripts, and code I'm comfortable sharing.*
