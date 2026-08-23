# n8.gay

Personal site. A [Hugo](https://gohugo.io) build on a vendored copy of the
[hello-friend](https://github.com/panr/hugo-theme-hello-friend) theme.

The homepage is a contact card rather than a post list — most visitors arrive from
a camera pointed at a QR code, so the first screen is who I am and how to reach me.
The blog still lives at `/blog`.

## Prerequisites

- [Nix](https://nixos.org/download)
- [direnv](https://direnv.net)

Hugo and the QR tooling come from `flake.nix`; nothing needs installing system-wide.

```sh
git clone git@github.com:nateinaction/n8.gay.git
cd n8.gay
direnv allow          # one time; brings the toolchain in
hugo server           # live preview at http://localhost:1313
hugo                  # build into public/
```

Without direnv, `nix develop` enters the same shell manually.

## Deploying — read this first

Cloudflare Pages **serves the committed `public/` directory and never runs Hugo.**

So a source change alone deploys nothing. Rebuild and commit the output together:

```sh
hugo --cleanDestinationDir
git add -A && git commit && git push
```

`--cleanDestinationDir` matters: without it, files that are no longer generated
linger in `public/` and keep getting served.

## The QR code

`static/qr.svg` and `static/qr.png` encode `https://n8.gay/`, and `/qr` is a page
that displays the code full-width for holding up to someone else's camera.

The PNG exists so it can be saved to a phone's camera roll — conference wifi is
unreliable, and a code that needs the network to load is a code you cannot show.

Regenerate if the URL ever changes:

```sh
qrencode -o static/qr.svg -t SVG -m 4 -l H "https://n8.gay/"
qrencode -o static/qr.png -t PNG -m 4 -l H -s 32 "https://n8.gay/"
```

`-m 4` supplies the four-module quiet zone the spec asks for. The poster repo uses
`-m 0` because Typst draws the quiet zone around it; here the file is displayed
directly, so it has to carry its own or scanners will not find the code. `-l H` is
the highest error correction — free at this URL length, and it buys tolerance for
glare and odd angles on a screen.

Verify what it actually encodes. A QR nobody can scan is worse than no QR, and you
cannot tell by looking at it:

```sh
rsvg-convert -w 600 static/qr.svg -o /tmp/qr.png
zbarimg -q /tmp/qr.png
# -> QR-Code:https://n8.gay/
zbarimg -q static/qr.png
# -> QR-Code:https://n8.gay/
```

## Layout

| Path | What it is |
|---|---|
| `layouts/index.html` | The homepage contact card, overriding the theme's post list |
| `layouts/_default/qr.html` | The `/qr` display page |
| `content/_index.md` | Card body copy |
| `static/nate.vcf` | vCard behind "Add to contacts". Needs CRLF line endings |
| `static/style.css` | Site overrides, loaded after the theme stylesheet |
| `themes/hello-friend/` | Vendored theme — see its `VENDORED.md` |
| `public/` | Build output. Committed, because that is what deploys |
