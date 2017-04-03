---
date: '2007-02-08 23:04:45'
layout: post
slug: integrating-google-checkout-with-webobjects
status: publish
title: Integrating Google Checkout With WebObjects
wordpress_id: '11'
categories:
- Programming
- WebObjects
---

I've been spending days on this. I kept getting messages that the socket to the app was being closed, and I couldn't find out why. 




	[2007-02-08 14:13:40 PST] <workerthread7> <wohttpio>: Unable to set socket timeout:Socket is closed  
	&lt;/wohttpio&gt;&lt;/workerthread7&gt;

Turns out that by calling


	com.google.checkout.sample.protocol.CallBackParser.getInstance().parseToJAXB(new InputSource(aRequest.contentInputStream()))


either jaxb, the xml parser, or the google code was closing the input stream returned by the request, which was closing the socket to the web server. Instead, I changed the code to

	com.google.checkout.sample.protocol.CallBackParser.getInstance().parseToJAXB(new InputSource(new java.io.StringReader(aRequest.contentString())))

and it works fine.

I figured I'd post this note so that if someone else runs into this problem, they'd hopefully find a solution via a Google search.
