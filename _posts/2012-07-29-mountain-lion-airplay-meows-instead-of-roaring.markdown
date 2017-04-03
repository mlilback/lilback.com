---
date: '2012-07-29 10:27:01'
layout: post
slug: mountain-lion-airplay-meows-instead-of-roaring
status: publish
title: AirPlay on Mountain Lion Meows Instead of Roaring
wordpress_id: '159'
categories:
- Apple
- Programming
tags:
- AirPlay
- Mountain Lion
---

As a developer, I was excited to see that Mountain Lion would support AirPlay. I could do all the same things from a Mac that I could from an iPad. Unfortunately, that isn't the case.
<!--more-->
For a technical breakdown of how desktop AirPlay is implemented, read [ArsTechnica article on AirPlay](http://arstechnica.com/apple/2012/07/mountain-lion-airplay-mirroring-v-airparrot-fight/). Basically it uses a technology called QuickSync that is in newer Intel graphics chips. So no matter how much better your discrete chip is, you've got to use the weaker Intel one to mirror. Which means you won't want to mirror Diablo 3.

Even worse, to my mind, is that only mirroring is allowed. On iOS, when a device is connected an app can show different content on the two windows (builtin, AirPlay). Apple promotes this heavily for use in games. This is not possible on the Mac. No second screen appears in the display list that you can use. 

<img src="/images/airplayDockBug.png" style="float:right;" width="65" 
height="380" alt="Bugging Dock when turning on AirPlay Mirroring">

It does appear that you can still show different content on a second display. For example, If I have a latop connected to an external monitor, the external monitor is mirrored to the AppleTV and it is possible to show a different interface on the laptop's builtin display. Unfortunately, that just an edge case not really usable as a way to sell a game.

Seems strange that if I want to have a game where a family can play using any Apple product, it has to be hosted on an iOS device instead of a Mac with multiple GPUs.

There is also a display bug if your Dock is on the left or right. I've filed that as <a href="rdar://problem/11982207">rdar://problem/11982207</a>.


