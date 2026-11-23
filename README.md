# www.rakefire.io

Source for [www.rakefire.io](https://www.rakefire.io), the Rakefire marketing site. Built with [Bridgetown](https://www.bridgetownrb.com/) and deployed to GitHub Pages from `main`.

## Stack

- Ruby (see `.ruby-version`)
- Bridgetown 2.x (`bridgetown-feed`, `bridgetown-sitemap`, `bridgetown-seo-tag`)
- Liquid templates in `src/`
- SCSS in `_sass/` compiled via `sass-embedded` to `src/css/style.css`

## Local development

```sh
bundle install
bundle exec bridgetown serve
```

Then open http://localhost:4000.

Production build:

```sh
BRIDGETOWN_ENV=production bundle exec bridgetown build
```

Output goes to `output/`.

## Tests

Specs in `test/` use Bridgetown's Minitest harness (`bridgetown/test` + rack-test) against the built `output/`: page metadata, broken internal links, redirects, sitemap/robots/feed, and the agent-skills/llms.txt files.

```sh
bundle exec bridgetown build && bundle exec rake test
```

## CSS

`src/css/style.css` is checked in as the byte-exact output of the legacy Jekyll/libsass build, so the deployed stylesheet matches the pre-Bridgetown site. If you change anything under `_sass/`, regenerate it:

```sh
bundle exec rake css:build
```

Note: `sass-embedded` (Dart Sass) emits a slightly different stylesheet than libsass did against this Bootstrap fork — diff the result before committing.

## Deploy

`.github/workflows/pages.yml` builds on every push to `main` and publishes to GitHub Pages (custom domain: `www.rakefire.io`). The specs run against that production build first; a failure blocks the deploy. IndexNow is pinged only after a successful deploy. Pull requests run the same build + specs without deploying or pinging. No manual deploy step.
