---
date: '2012-07-03 11:59:30'
layout: post
slug: yojimbo-syncing-via-dropbox-with-multiple-macs
status: publish
title: Yojimbo syncing via Dropbox with multiple Macs
wordpress_id: '143'
categories:
- Software
tags:
- Dropbox
- Yojimbo
---

 





[Ben Brooks](http://brooksreview.net/2012/06/yojimbo-sync/) wrote about the problems with using Dropbox and multiple Macs, offering a solution using Keyboard Maestro. Here is the solution I've been using for a while. Save the following AppleScript and set it up as a Folder Action in your Dropbox on each machine (you must do it on both machines if you want it to work both ways).

<!--more-->

``` applescript
on adding folder items to this_folder after receiving added_items
	repeat with i from 1 to number of items in added_items
		set new_item to item i of added_items
		if (name of (info for new_item)) is "quit.txt" then
			tell application "Finder"
				delete new_item
				set isRunning to false
				tell application "System Events" to set isRunning to ((name of processes) contains "Yojimbo")
				if isRunning then
					tell application "Yojimbo"
						quit
					end tell
				end if
			end tell
		end if
	end repeat
end adding folder items to

on appIsRunning(appName)
	tell application "System Events" to (name of processes) contains appName
end appIsRunning
```



Then anytime you add something to the folder, Yojimbo will quit. A great way to quit Yojimbo on your office computer from home.


