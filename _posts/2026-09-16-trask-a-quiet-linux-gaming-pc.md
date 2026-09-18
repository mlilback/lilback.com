---
title: 'Trask: my new PC is quiet'
date: '2026-09-16 19:40:00'
layout: post
categories:
- Computers
- Gaming
- Linux
tags: [AMD, Bazzite, Linux, PC build, noise]
author: mlilback
---

I replaced my gaming PC last week. The old one was a five-year-old OriginPC NEURON -- Ryzen 9 5900X, Radeon RX 6800 XT, perfectly good hardware that I only used in binges. Five years, 2,020 power-on hours. It was loud -- I only used it when actively playing a game because I could barely hear myself think.

So the new machine had exactly one goal ahead of all the others: be quiet. Everything else followed from that, including the parts I didn't buy. I named it [trask](https://darkshadows.fandom.com/wiki/Reverend_Trask), which keeps it in line with [my naming scheme]({% post_url 2026-09-14-how-i-name-my-computers %}).


The build, with what it replaced:

- CPU: Ryzen 7 9800X3D, 8C/16T, 120W -- was a Ryzen 9 5900X, 12C/24T, 105W TDP and 142W PPT
- Cooler: be quiet! Dark Rock Pro 5, air -- was a Corsair H100i Pro XT 240mm AIO
- Motherboard: MSI MAG X870E Tomahawk WiFi -- was an ASRock B550 Phantom Gaming 4/ac
- Memory: 32GB DDR5-6000 CL30 -- was 32GB DDR4-3000 CL15
- GPU: Sapphire PULSE RX 9070 XT 16GB -- was a Gigabyte RX 6800 XT GAMING OC 16G
- Storage: Crucial P310 2TB, plus an Acer Predator GM7000 2TB for games -- was a 1TB MP600 and a 1TB 870 QVO
- PSU: be quiet! Pure Power 13 M, 850W -- was a Corsair RM750x, 750W
- Case: be quiet! Pure Base 501 DX -- was a Corsair 175R
- Monitor: Alienware AW3225QF, 32" 4K 240Hz QD-OLED, $780 from Dell -- was a Dell S3221QS, 32" 4K 60Hz

About $2,700 for the box, and just over $3,500 once the monitor is in it. The old machine gets sold intact, because a complete working system is worth more than what I'd get for stripping it. I figured I'd bite the bullet and get a new system now, before prices rise even more.

Four of those choices are noise choices:

- AMD instead of Intel/NVIDIA -- while CUDA would be nice for work, my Mac Studio with 128 GB of RAM is better for AI inference than any NVIDIA card I could reasonably afford.
- Air instead of an AIO, because a pump is both a noise source and a wear item, and I've had one start whining three years in.
- The Sapphire Pulse instead of the Nitro+. [TechPowerUp's numbers](https://www.techpowerup.com/review/sapphire-radeon-rx-9070-xt-pulse/39.html) have the Pulse at 25.5 dBA gaming against the Nitro OC's 26.5, which is nothing, but it also pulls 314W against 351W and runs a 78°C hotspot against 83°C. It was the quietest, coolest and least power-hungry card in the comparison, and it was cheaper than the Nitro. The die is identical across every card in that price range -- what you're paying for is the cooler.
- The 9800X3D instead of the 9950X3D, which is a 170W part against 120W. More cores I don't need in exchange for 50 more watts of heat to move quietly. No thanks.

The monitor is on that list because speccing this thing made me realize it was the actual bottleneck. The old one ran 4K at 60Hz, and at 4K60 you're always GPU-bound. Which means the expensive CPU I was buying wouldn't have shown up in average framerate at all. Buying the 9800X3D without the monitor would have been buying a part I couldn't use.

One warning if you do the same with an AMD card. The 9070 XT does DisplayPort 2.1 UHBR13.5, not UHBR20. It drives 4K240 with DSC and looks fine, but every monitor charging a premium for UHBR20 is charging you for bandwidth this card can't use.

It runs [Bazzite](https://bazzite.gg), which is Fedora atomic with the gaming stack already assembled. I've left it open to dual boot or use a VM for Windows when I need it for certain games (and for testing for work, which offered to buy me a license).

Now the numbers, because this was the whole point. At idle the case fans sit at 565 RPM with the system sensor at 39.5°C. I ran [OCCT](https://www.ocbase.com)'s 3D Adaptive test for twenty minutes at about 313W of board power, and the system sensor settled at 50°C with the fans at 985 RPM -- 75% duty on a fan that tops out near 1,250. GPU junction peaked at 84°C, VRAM at 94°C, and the CPU never got past 57.8°C.

Compare that to the old machine's last OCCT run, an hour of combined CPU and GPU load in August: the 5900X peaked at 90.25°C on one die and 91.50°C on the other, against a Tjmax of 90. Zero errors, and the chip clocked down to hold the limit like it's supposed to, but the H100i with five-year-old paste was done. That's not a controlled comparison -- one run was combined load and the other was GPU only -- but a cooler that's pinned at its limit is a cooler running its fans flat out, and that is exactly the noise I was paying to get rid of.

At full GPU load on the new one, the fans are at three-quarters speed and I can barely hear them.

I did try steepening the fan curve and it buys a degree, maybe two. The ceiling is the case, not the curve -- one low front intake is what decides where the temperature lands.

Next post: getting Mass Effect Legendary Edition modded on it, which took an entire evening and a lot of swearing.
