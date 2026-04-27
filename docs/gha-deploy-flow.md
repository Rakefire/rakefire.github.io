---
marp: true
theme: default
paginate: true
title: rakefire.io — GHA Deploy Flow
---

# GHA Deploy Flow

**rakefire.io**

Bridgetown 2.1 → GitHub Pages

Single workflow: `.github/workflows/pages.yml`

---

## Triggers

- `push` to `main` / `master`
- `schedule: "0 6 * * *"` — daily 06:00 UTC rebuild
- `workflow_dispatch` — manual

**Permissions**

- `contents: read`, `pages: write`, `id-token: write`

**Concurrency**

- `group: pages`, `cancel-in-progress: false` — runs queue, never get killed mid-flight

---

## Two jobs: `build` → `deploy`

```
build (ubuntu-latest)
  └─ checkout → setup ruby/node → npm ci → rake deploy → upload artifact

deploy (ubuntu-latest, needs: build)
  └─ actions/deploy-pages@v5
```

Note: this repo runs **newer action versions** than its siblings —
`checkout@v6`, `configure-pages@v6`, `upload-pages-artifact@v5`,
`deploy-pages@v5`.

---

## `build` job — environment setup

1. `actions/checkout@v6`
2. `ruby/setup-ruby@v1` — Ruby `4.0.3`, `bundler-cache: true`
   - Caches `vendor/bundle` keyed off `Gemfile.lock`
3. `actions/setup-node@v4` — Node 20, `cache: npm`
4. `npm ci` — installs esbuild + postcss toolchain
5. `actions/configure-pages@v6`

**No Tailwind, no Puppeteer.** Only the Bridgetown 2.x esbuild defaults.

---

## The build step

```yaml
- run: bundle exec rake deploy
  env:
    BRIDGETOWN_ENV: production
```

Everything interesting happens inside `rake deploy`.

---

## `rake deploy` — task chain

```
clean
  → frontend:build
  → Bridgetown::Commands::Build.start
```

Single Bridgetown build — no second pass, no OG regen.

---

## Step 1 — `:clean`

`Bridgetown::Commands::Clean.start`

- Wipes `output/`
- Wipes `.bridgetown-cache`

No incremental build state survives across runs.

---

## Step 2 — `frontend:build`

```
npm run esbuild
  → node esbuild.config.js --minify
```

- Bundles `frontend/javascript/index.js` + `frontend/styles/index.css`
- Output lands in `output/_bridgetown/static/` during the Bridgetown build
- Today the entries are stubs — esbuild is scaffolding for future JS/CSS

The vendored jQuery/Bootstrap JS in `src/js/` and the precompiled
`src/css/style.css` continue to load via plain `<script>` / `<link>` tags.
**esbuild is additive, not a replacement.**

---

## Step 3 — Bridgetown build

Generates `output/` from `src/`.

**Site builders run on `:post_write` hooks** (`plugins/builders/`):

| Builder | What it does |
|---|---|
| `agent_skills` | Writes `.well-known/agent-skills/index.json` + skill files |
| `api_catalog` | Linkset → agent-skills index |
| `markdown_for_agents` | Emits markdown twins of HTML pages |
| `redirects` | Generates redirect HTML files from data |
| `html_minifier` | `htmlcompressor` rewrites every `output/**/*.html` |
| `indexnow` | Pings IndexNow API (production only) |

---

## Where does the CSS come from?

Not built in CI. The repo commits `src/css/style.css` directly.

**Source of truth (legacy):** `_sass/blue.scss` (old Bootstrap)

**Rebuild path** (manual, local-only):

```
rake css:build
  → sass-embedded compiles _sass/blue.scss
    with Dart Sass, style: :compressed
  → writes src/css/style.css
```

⚠️ `_sass/blue.scss` carries a top-of-file warning: editing it does **not**
change the deployed CSS. Dart Sass also emits a different stylesheet from
this old Bootstrap than libsass did, so always diff before committing
any rebuild.

---

## Bridgetown config

`config/initializers.rb`:

```ruby
Bridgetown.configure do |config|
  url "https://www.rakefire.io"

  init :"bridgetown-feed"
  init :"bridgetown-sitemap"
  init :"bridgetown-seo-tag"
end
```

Three gem-based plugins handle feed / sitemap / SEO tags.
No custom site-level config beyond URL.

---

## Sitemap, feed, robots

Three different sources:

| File | Source |
|---|---|
| `/sitemap.xml` | `bridgetown-sitemap` gem |
| `/feed.xml` | `bridgetown-feed` gem |
| `/robots.txt` | `src/robots.txt` (committed) |

SEO meta tags injected via `bridgetown-seo-tag` gem.

The IndexNow builder reads `output/sitemap.xml` post-write.

---

## IndexNow submission

`plugins/builders/indexnow.rb` — fires on `:post_write` when:

- `BRIDGETOWN_ENV == "production"`, **or**
- `INDEXNOW=true`

**Flow**

1. Read `output/sitemap.xml`
2. Parse with `REXML`, collect `urlset/url/loc`
3. POST to `https://api.indexnow.org/indexnow`:
   ```json
   {
     "host": "www.rakefire.io",
     "key": "d3edebe3-…",
     "keyLocation": "https://www.rakefire.io/<key>.txt",
     "urlList": [...]
   }
   ```
4. 10s open/read timeouts
5. Exceptions caught and logged — never fail the build

Key file: `src/d3edebe3-2774-4cd0-b3aa-780a8587c0a6.txt`

---

## HTML minifier

`plugins/builders/html_minifier.rb`

```ruby
HtmlCompressor::Compressor.new(
  remove_comments: true,
  remove_multi_spaces: true,
  remove_intertag_spaces: false,
  preserve_line_breaks: false
)
```

- Walks `Dir.glob("#{site.dest}/**/*.html")`
- Rewrites every file in place
- Skipped when `config[:watch]` (dev server)

---

## Artifact + deploy

```yaml
- uses: actions/upload-pages-artifact@v5
  with:
    path: output

deploy:
  needs: build
  steps:
    - uses: actions/deploy-pages@v5
```

GitHub Pages serves the artifact behind the `CNAME` (`www.rakefire.io`).

---

## Caching summary

| Layer | Cached? |
|---|---|
| `vendor/bundle` | ✅ via `bundler-cache: true` |
| `node_modules` | ✅ via `actions/setup-node` `cache: npm` |
| `output/` | ❌ wiped by `:clean` |
| `.bridgetown-cache` | ❌ wiped by `:clean` |
| `src/css/style.css` | ✅ effectively — committed file |
| Pages artifact | ❌ no inter-run reuse |

The committed CSS is what makes this site cheap to rebuild.

---

## Notable per-run side effects

- **IndexNow** — single POST per production / cron run
- **HTML minifier** — every `output/**/*.html` rewritten in place
- **Full rebuild** every time — no incremental Bridgetown
- **Build failures in IndexNow are swallowed** — logged, never raised
- **Concurrency queue** — pushes during a run wait, don't cancel
- **CSS is whatever was last committed** — drift between `_sass/` and `src/css/style.css` is silent unless someone runs `rake css:build`

---

## Failure modes to know about

- **`_sass/` edits without `rake css:build`** → no visible change in deploy
- **IndexNow rate limits** — silent in current code; only HTTP code is logged
- **Concurrency queue** — long builds block subsequent pushes
- **Newer action versions** → if GitHub deprecates `v5`/`v6`, this is the first site to break

---

## Files / paths to know

```
.github/workflows/pages.yml          # the workflow
Rakefile                             # :deploy + frontend:build + css:build
package.json                         # esbuild + postcss
esbuild.config.js                    # entry → config/esbuild.defaults.js
config/esbuild.defaults.js           # Bridgetown 2.x esbuild defaults
config/initializers.rb               # url + 3 gem inits
frontend/javascript/index.js         # JS entry (stub today)
frontend/styles/index.css            # CSS entry (stub today)
_sass/blue.scss                      # legacy Bootstrap (reference-only)
src/css/style.css                    # committed compiled output
src/d3edebe3-…txt                    # IndexNow key file
plugins/builders/
  ├── agent_skills.rb
  ├── api_catalog.rb
  ├── html_minifier.rb               # post-build compression
  ├── indexnow.rb                    # IndexNow submission
  ├── markdown_for_agents.rb
  └── redirects.rb
src/robots.txt
```

---

# End

Questions?
