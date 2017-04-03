---
date: '2010-10-07 17:41:56'
layout: post
slug: always-initialize-pointers-to-nil
status: publish
title: Always initialize pointers to nil
wordpress_id: '93'
categories:
- Programming
tags:
- cocoa
- debugging
---

I'm working on a pretty complex custom application for a client. It allows them to visually build complicated products for their website. Kinda like a Quark lite.

Anyway, I wanted to add some fancy Core Animation effects when I'm opening a window for the user to select an image to include. It worked great, until I tried running the version my build script uploaded. It kept crashing as soon as I tried to load the image loading code.

I eventually figure it must be a difference between Debug and Release targets, and low-and-behold, it is. In the release version, in some 3rd party code I included, they didn't initialize a pointer.


> `NSImage *image;`


I added `=nil` and the application no longer crashes.

I'm pretty certain I do this 99.9% of the time, but I'm going to be more vigilant when inspecting code written by others. And I'm making it a point to do more testing with a build of the Release target.
