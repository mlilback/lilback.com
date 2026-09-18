# lilback.com

Mark's personal blog. Jekyll + the **Chirpy** theme, published as
**www.lilback.com** from this repo (`mlilback/mlilback.github.io`) via GitHub
Pages.

## The two things that bite

- **The branch is `master`, not `main`.** `.github/workflows/pages-deploy.yml`
  builds and deploys on every push to `master` — a push *is* a publish.
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

## Local build

Ruby 3.3.9 via mise (`.mise.toml`, `.ruby-version`):

    bundle install
    bundle exec jekyll s      # preview at localhost:4000

## Posting without a clone

`.github/workflows/create-post.yml` is a `workflow_dispatch` taking title,
category, tags and a Markdown body; it generates the file, commits and deploys.
That is the from-the-phone path. From the Mac, write the file and push.
