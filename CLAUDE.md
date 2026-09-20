# lilback.com

Mark's personal blog. Jekyll + the **Chirpy** theme, published as
**www.lilback.com** from this repo (`mlilback/lilback.com`) by a **Cloudflare
Worker**. GitHub Pages was retired 2026-09-20 -- it offered no logs or
analytics.

## The two things that bite

- **The branch is `master`, not `main`.** `.github/workflows/pages-deploy.yml`
  builds and runs `wrangler deploy` on every push to `master` — a push
  *is* a publish.
- **`permalink: /:title/` in `_config.yml` is deliberate.** It preserves the
  URL structure from before the Chirpy migration. Changing it breaks every
  existing inbound link.

## Layout

    _posts/      posts, YYYY-MM-DD-slug.md (older ones .markdown)
    _tabs/       about, archives, categories, tags
    _data/       authors.yml, contact.yml, share.yml
    _plugins/    posts-lastmod-hook.rb
    images/      post images (NOT assets/, which is theme css/img)
    eino/        a standalone older sub-site, kept as-is

## Writing a post

Copy the front matter from a recent post:

```yaml
---
title: Introducing Alcove
date: '2026-05-17 19:19:44'
layout: post
categories:
- Alcove
- Apple
- Programming
tags: [swift, AppKit, Claude Code, ebooks]
author: mlilback
---
```

`categories` are capitalized and broad (Personal, Programming, Apple, Computers,
Pet Peeves, Comedy, Society, Alcove). `tags` are specific. `author: mlilback`
resolves through `_data/authors.yml`.

## Post images and social cards

`image:` in a post's front matter sets `og:image` **and** renders the image as a
banner at the top of the post -- Chirpy gives you both or neither.

```yaml
image:
  path: /images/whatever.jpg
  alt: Describes the image, and becomes the banner's caption
```

Cards are **1.91:1**; 1200x628 is the target. `scripts/social-card.swift` crops a
screenshot to a card, optionally painting over a stray desktop icon:

    swift scripts/social-card.swift shot.png --info
    swift scripts/social-card.swift shot.png images/out.jpg --rect X Y W H \
        [--patch X Y W H] [--width 1200] [--quality 0.82]

Use it rather than `sips`: sips' `--cropOffset` is measured from the *centered*
crop, not the top-left, and negative offsets misbehave.

## Hosting and analytics

The site is a **Cloudflare Worker with static assets** (`wrangler.jsonc`,
`src/index.js`), not a Pages project. The same Worker serves `_site` and
collects pageviews at `/beacon` -- no cookies, no client storage, no
third-party script. Uniques are a hash of IP + UA + the date, so the value
rotates daily.

    wrangler deploy          # from the Mac; CI does the same on push

Two traps:

- **`cloudflare/wrangler-action@v3` installs wrangler 3.90 by default**, which
  cannot parse `wrangler.jsonc` and fails with "Missing entry-point". The
  workflow pins `wranglerVersion`.
- **Anything at the repo root that Jekyll doesn't recognise gets copied into
  `_site` and published.** `src/index.js` was served as a static asset by the
  first deploy. `src`, `wrangler.jsonc`, `scripts` and `CLAUDE.md` are in
  `exclude:` for this reason.

Query the data with the SQL API against dataset `blog_hits`; blob positions
are documented in `src/index.js` and queries are kept in `scripts/queries.sql`.

Don't connect Cloudflare's git integration: `_plugins/posts-lastmod-hook.rb`
shells out to `git` and needs full history, which is why CI checks out with
`fetch-depth: 0`.

## Local build

Ruby 3.3.9 via mise (`.mise.toml`, `.ruby-version`):

    bundle install
    bundle exec jekyll s      # preview at localhost:4000

## Posting without a clone

`.github/workflows/create-post.yml` is a `workflow_dispatch` taking title,
category, tags and a Markdown body; it generates the file, commits and deploys.
That is the from-the-phone path. From the Mac, write the file and push.
