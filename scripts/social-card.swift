#!/usr/bin/env swift
//
// social-card.swift -- crop a screenshot into a social card (or any post image).
//
//   swift scripts/social-card.swift <in.png> <out.jpg> --rect X Y W H [options]
//
// Cards are 1.91:1. The default output is 1200 wide, which makes a 1200x628
// card -- what Mastodon, Bluesky and every OpenGraph consumer want.
//
// Options:
//   --width N            output width in pixels (default 1200)
//   --quality 0.0-1.0    JPEG quality (default 0.82)
//   --patch X Y W H      paint over a rectangle (a stray desktop icon, say)
//   --patch-from X       column to copy the patch color from, per row, so a
//                        wallpaper gradient continues through it seamlessly.
//                        Defaults to 40px left of the patch.
//   --info               print the image's dimensions and exit
//
// Why this exists rather than sips: sips' --cropOffset is measured from the
// CENTERED crop, not from the top-left, and negative offsets misbehave. This
// takes an explicit rect in top-left coordinates, which is what you measured
// off the screenshot.
//
// Finding the rect: open the screenshot in Preview, select the region, and
// read the selection size in the toolbar -- or run with --info and work from
// the full dimensions. Retina screenshots are 2x the logical size.
//
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func die(_ msg: String) -> Never { fputs("social-card: \(msg)\n", stderr); exit(1) }

var args = Array(CommandLine.arguments.dropFirst())
func flag(_ name: String, _ count: Int) -> [Int]? {
    guard let i = args.firstIndex(of: name) else { return nil }
    guard args.count > i + count else { die("\(name) needs \(count) value(s)") }
    let vals: [Int] = args[(i + 1)...(i + count)].map {
        guard let n = Int($0) else { die("\(name): '\($0)' is not a number") }
        return n
    }
    args.removeSubrange(i...(i + count))
    return Array(vals)
}
func doubleFlag(_ name: String) -> Double? {
    guard let i = args.firstIndex(of: name) else { return nil }
    guard args.count > i + 1, let v = Double(args[i + 1]) else { die("\(name) needs a number") }
    args.removeSubrange(i...(i + 1))
    return v
}

let wantsInfo = args.contains("--info")
args.removeAll { $0 == "--info" }
let rect = flag("--rect", 4)
let patch = flag("--patch", 4)
let patchFrom = flag("--patch-from", 1)?.first
let outWidth = flag("--width", 1)?.first ?? 1200
let quality = doubleFlag("--quality") ?? 0.82

guard let inPath = args.first else { die("usage: social-card.swift <in> <out> --rect X Y W H") }
guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { die("cannot read \(inPath)") }

if wantsInfo {
    print("\(img.width)x\(img.height)")
    let ratio = Double(img.width) / Double(img.height)
    print(String(format: "aspect %.3f:1  (a card is 1.910:1)", ratio))
    exit(0)
}

guard args.count >= 2 else { die("no output path") }
let outPath = args[1]
guard let r = rect else { die("--rect X Y W H is required") }
let (rx, ry, rw, rh) = (r[0], r[1], r[2], r[3])
guard rx >= 0, ry >= 0, rx + rw <= img.width, ry + rh <= img.height else {
    die("rect \(rx),\(ry) \(rw)x\(rh) falls outside the \(img.width)x\(img.height) image")
}
let ratio = Double(rw) / Double(rh)
if abs(ratio - 1.91) > 0.03 {
    fputs(String(format: "social-card: warning -- rect is %.2f:1, cards are 1.91:1; it will be letterboxed or cropped\n", ratio), stderr)
}

// Redraw into a bitmap we can paint on. NOTE: a CGBitmapContext's memory is
// stored top-down, even though CG's drawing coordinates are bottom-up.
guard let ctx0 = CGContext(data: nil, width: img.width, height: img.height, bitsPerComponent: 8,
                           bytesPerRow: img.width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                           bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { die("no context") }
ctx0.draw(img, in: CGRect(x: 0, y: 0, width: img.width, height: img.height))

if let p = patch {
    let (px, py, pw, ph) = (p[0], p[1], p[2], p[3])
    let column = patchFrom ?? max(0, px - 40)
    guard column >= 0, column < img.width else { die("--patch-from \(column) is outside the image") }
    let buf = ctx0.data!.assumingMemoryBound(to: UInt8.self)
    let bpr = ctx0.bytesPerRow
    for y in py..<min(py + ph, img.height) {
        let row = y * bpr
        let s = row + column * 4
        let (cr, cg, cb) = (buf[s], buf[s + 1], buf[s + 2])
        for x in px..<min(px + pw, img.width) {
            let o = row + x * 4
            buf[o] = cr; buf[o + 1] = cg; buf[o + 2] = cb
        }
    }
}

guard let painted = ctx0.makeImage(),
      let cropped = painted.cropping(to: CGRect(x: rx, y: ry, width: rw, height: rh)) else { die("crop failed") }

let scale = Double(outWidth) / Double(cropped.width)
let outHeight = Int((Double(cropped.height) * scale).rounded())
guard let ctx = CGContext(data: nil, width: outWidth, height: outHeight, bitsPerComponent: 8,
                          bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { die("no context") }
ctx.interpolationQuality = .high
ctx.draw(cropped, in: CGRect(x: 0, y: 0, width: outWidth, height: outHeight))

guard let scaled = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL,
                                                 UTType.jpeg.identifier as CFString, 1, nil) else { die("cannot write \(outPath)") }
CGImageDestinationAddImage(dest, scaled, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
guard CGImageDestinationFinalize(dest) else { die("write failed") }

let bytes = ((try? FileManager.default.attributesOfItem(atPath: outPath)[.size]) as? Int) ?? 0
print("\(rw)x\(rh) -> \(outWidth)x\(outHeight), \(bytes / 1024)KB, \(outPath)")
