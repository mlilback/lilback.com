---
date: '2010-12-01 13:33:38'
layout: post
slug: one-line-shell-script-to-count-lines-of-source-code
status: publish
title: One line shell script to count lines of source code
wordpress_id: '106'
categories:
- Programming
tags:
- MacSQL
- programming
- shell script
- unix
---

Yes, I know counting lines of code isn't an effective way to measure the complexity of a project. But it does offer an easy way to compare the size of different projects. So here's a one line command/script to give you a count of all source files in the current directory and all subdirectories.


``` sh
rm -f src-line-count; \
find . \( -name "*.m" -or -name "*.h" -or -name "*.c" -or -name "*.cpp" -or -name "*.mm" \) \
	-exec cat {} \;  wc -l
```


I'm working on two new products that will be released this year. My shared folder of code used across multiple projects is 4348. Project 1 is largely complete and is 3508 lines. Project 2 still has a ways to go and is 5495 lines. I'll probably add another 2000 lines before it ships.

The big doozy is MacSQL and the MacSQL Framework. I haven't updated them in a long time, and a big part was health problems and other issues in my life the last few years. But even trying to tackle modernizing that code is scary. It totals 158,193 lines of code. And I wrote 99.9% of that code myself. That does not include third party frameworks and source code, which is kept in a separate location that I didn't bother to count because all of that code isn't used. 

_Updated_: Made adjustments from Nathan Phillip Brink's comment. Thanks, Nathan!
