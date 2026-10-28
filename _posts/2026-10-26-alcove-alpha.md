---
title: Alcove Is in Alpha
date: '2026-10-26 12:00:00'
layout: post
categories:
- Alcove
- Apple
tags: [ebooks, TestFlight, iCloud]
author: mlilback
image:
  path: /images/alcove-alpha.jpg
  alt: "Alcove's reader on a Mac and an iPad, both open at the same page of 2001: A Space Odyssey."
---

I shipped the first Alpha of [Alcove](https://alcoveapp.app) to TestFlight on October 22nd. Three days and 47 commits later I shipped a second one, and that's the one I want people to try.

It runs on the Mac and the iPad (macOS 15.7 or iPadOS 18.4 and later). There's no iPhone version yet. It imports EPUB, PDF, MOBI, and AZW3 files, and on the Mac a whole Calibre library with its series, tags, and covers. iCloud syncs a library between your devices, and each library can download books on demand or keep all of them local.

The big change in the second build is a reader. EPUBs, PDFs, and comics open inside Alcove now, and your reading position follows you from the Mac to the iPad and back. You can still send a book to Apple Books or anything else if you'd rather.

It also has the first pieces of Alcove Plus, the subscription that pays for the server side: metadata lookups from [ISBNdb](https://isbndb.com) and AI help with tags and series. Subscriptions in TestFlight are sandbox purchases, so they cost testers nothing.

It's rough. Expect bugs, and expect things to change between builds. What I want from testers is real libraries, the bigger and messier the better, because my test libraries are only as weird as I can think to make them.

To get in, sign up at [alcoveapp.app/beta](https://alcoveapp.app/beta) and you'll get a TestFlight invite. Bugs and feature requests go to the [feedback board](https://feedback.alcoveapp.app), where you can vote on what gets built next.

When I [introduced Alcove](/introducing-alcove/) in May I said it would eventually be a reader. Eventually turned out to be five months.
