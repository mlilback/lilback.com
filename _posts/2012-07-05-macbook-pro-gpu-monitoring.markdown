---
date: '2012-07-05 17:09:01'
layout: post
slug: macbook-pro-gpu-monitoring
status: publish
title: MacBook Pro GPU Monitoring
wordpress_id: '158'
categories:
- Apple
- Software
tags:
- GPU
- MacBook Pro
- NetNewsWire
---

I just found a really great app called [gfxCardStatus](http://codykrieger.com/gfxCardStatus) that works with any 2008 or later MacBook Pro. It is a menu-bar app that shows you which GPU is currently being used. Keeping it down to the Intel GPU decreases the heat generated and increases battery life.

I was amazed to find that one of the apps I always have running, NetNewsWire, switches to the Nvidia GPU when running. Which means my usage pattern was causing a lot of heat and reducing my battery life.

Another great feature of gfxCardStatus is that you can turn off dynamic GPU switching and force a particular one to be used. I'm leaving mine on dynamic for a while, just to see which apps cause a switch. But I imagine that soon my normal procedure will be to disable dynamic switching.
