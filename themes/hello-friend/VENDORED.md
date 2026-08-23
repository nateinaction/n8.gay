# hello-friend (vendored)

A vendored snapshot of [panr/hugo-theme-hello-friend](https://github.com/panr/hugo-theme-hello-friend),
MIT licensed — see `LICENSE.md`. Not a submodule; edit the files here directly.

## Local changes

Applied when the site moved from Hugo 0.87 to 0.164, which removed the APIs these
used:

- `layouts/_default/baseof.html` — dropped the `.Site.GoogleAnalytics` block.
  Removed in Hugo 0.120, and GA was never configured here anyway.
- `layouts/_default/rss.xml` — `.Site.Author` and `.Site.Copyright` became
  `.Site.Params.author` / `.Site.Params.copyright`, and `.Site.LanguageCode`
  became `.Site.Language.Locale`.

## What was removed, and why

Upstream ships a webpack/PostCSS toolchain that compiles `assets/css/*` and
`assets/js/*` into `static/assets/style.css` and `static/assets/main.js`. Those
outputs are committed, and **nothing in this repo ever ran that toolchain** — no
layout uses Hugo Pipes, so Hugo just copies the prebuilt files verbatim.

Deleted: `package.json`, `yarn.lock`, `webpack.config.js`, `babel.config.js`,
`postcss.config.js`, `.eslintrc.yml`, `.prettierrc`, `assets/`, `exampleSite/`,
`images/` (Hugo gallery screenshots), and the upstream community docs.

The `yarn.lock` alone pinned 957 packages at 2021 versions and was the sole source
of all 80 of this repo's Dependabot alerts — none of which could affect the site,
since that code ran neither at build time nor in a browser. Rebuilding `public/`
after the deletion produced byte-identical output, confirming all of it was dead.

## Styling the site

Override in `/static/style.css`, which loads after the theme's stylesheet. That is
where the homepage contact card is styled. Restyling the theme from its own sources
now means pulling them from upstream or from this repo's git history.
