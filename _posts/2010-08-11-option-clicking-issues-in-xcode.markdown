---
date: '2010-08-11 13:23:35'
layout: post
slug: option-clicking-issues-in-xcode
status: publish
title: Option Clicking Issues in Xcode
wordpress_id: '50'
categories:
- Apple
- Programming
tags:
- defaults
- nstextview
- text selection
- xcode
---

Starting with Leopard, NSTextView added support for rectangular selections and non-contiguous selections. Personally I've never used these features. However, they do get in my way.

You make a rectangular selection by holding the option key while you click and drag. For one, this changes the cursor to a crosshair that just looks wrong to me in a text view. Also, it interferes with drag a dropping a copy of some text.

<!--more-->

Say I need to duplicate a string. Say I'm implementing initWithCoder: and encodeWithEncoder:. I'll copy paste a bunch of lines real fast, like:


> 
>     -(id)initWithCoder:(NSEncoder*)coder
>     {
>     	self = [super init];
>     	self.value1 = [coder decodeObjectForKey:@"AM_SOMECLASS_VAL1"];
>     	self.value2 = [coder decodeObjectForKey:@"AM_SOMECLASS_VAL2"];
>     	self.value3 = [coder decodeObjectForKey:@"AM_SOMECLASS_VAL3"];
>     	return self;
>     }
>     -(void)encodeWithCoder:(NSCoder*)coder
>     {
>     	[coder encodeObject: self.value1 forKey:@""];
>     	[coder encodeObject: self.value2 forKey:@""];
>     	[coder encodeObject: self.value3 forKey:@""];
>     }
>     



Instead of typing the keys a second time, I'm going to quickly double click on a key in initWithCoder:, hold down option, and drag the key inside the appropriate line in encodeWithCoder:. That will work just like copy/paste, but I don't have to switch between mouse and keyboard and it doesn't erase whatever I have stored on the pasteboard.

Since Apple added rectangular selection, this would screw up a lot as I'd hit the option key too early and it would start a rectangular selection, not a drag-copy.

So I googled for a way to disable this, and boy did I have a hard time. And the solution is the defaults key NSProhibitMultipleTextSelectionByMouse. A google search returns only 3 links, the third one being to an old link to the older AppKit Release Notes.

So finally, here's the solution. Use this command to disable this in Xcode:


> defaults write com.apple.Xcode NSProhibitMultipleTextSelectionByMouse -bool YES



or disable it globally, as I did:


> defaults write NSGlobalDomain NSProhibitMultipleTextSelectionByMouse -bool YES



This post is pretty verbose, but I really wanted to discuss this enough to make sure anyone else googling for this problem would find this and save themselves a lot of time.
