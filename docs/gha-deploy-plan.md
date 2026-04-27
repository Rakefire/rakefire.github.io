# rakefire.io — GHA deploy alignment plan

**Repo:** `~/github/www-rakefire-io`
**Goals:**
1. Bump Ruby `4.0` → `4.0.3`
2. Add daily 06:00 UTC rebuild cron
3. **Bootstrap esbuild scaffolding** (no Node toolchain today) and run frontend in CI
4. Add a `:deploy` task to the Rakefile so the workflow can call it
5. Port IndexNow + HTML minifier builders from Stoked
6. Add a top-of-file warning to `_sass/blue.scss` (legacy Bootstrap, reference-only)
7. Update `docs/gha-deploy-flow.md`

This is the largest of the four plans because Rakefire has no Node setup at all today.

## Site facts

- **Site URL:** `https://www.rakefire.io` (from `config/initializers.rb` and `CNAME`)
- **IndexNow key (generated):** `d3edebe3-2774-4cd0-b3aa-780a8587c0a6`
- **CSS source-of-truth note:** `src/css/style.css` is committed byte-exact libsass output. `_sass/blue.scss` is reference-only — do **not** add a CSS rebuild to CI. See Change 8.

## Pre-flight

```bash
cd ~/github/www-rakefire-io
git status                            # expect clean
ls package.json esbuild.config.js     # expect no match — none today
grep -E "task.*deploy" Rakefile       # expect no match — Rakefile only has css:build today
```

## Change 1 — Workflow updates

**File:** `.github/workflows/pages.yml`

Replace entire file with:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main, master]
  schedule:
    - cron: "0 6 * * *"  # Rebuild daily at 6am UTC
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "4.0.3"
          bundler-cache: true

      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install npm dependencies
        run: npm ci

      - name: Setup Pages
        uses: actions/configure-pages@v6

      - name: Build site
        run: bundle exec rake deploy
        env:
          BRIDGETOWN_ENV: production

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v5
        with:
          path: output

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
```

Changes vs current:
- Add `schedule:` cron
- Ruby `4.0` → `4.0.3`
- Add `actions/setup-node@v4` step
- Add `npm ci` step
- Build command: `bundle exec bridgetown build` → `bundle exec rake deploy`

## Change 2 — Rakefile: add :deploy task chain

**File:** `Rakefile`

Replace entire file with (preserves the existing `css:build` task):

```ruby
require "bridgetown"

Bridgetown.load_tasks

task default: :deploy

desc "Build the Bridgetown site for deployment"
task :deploy => [:clean, "frontend:build"] do
  Bridgetown::Commands::Build.start
end

desc "Runs the clean command"
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "npm run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "npm run esbuild-dev"
  rescue Interrupt
  end
end

# CSS rebuild task. The committed src/css/style.css is the byte-exact output
# from Jekyll's libsass build, kept verbatim so the Bridgetown deploy renders
# identically. If you edit _sass sources, run `rake css:build` — but note that
# Dart Sass (sass-embedded) emits a different stylesheet from this old Bootstrap
# than libsass did. Check the diff before committing.
namespace :css do
  desc "Compile _sass/blue.scss to src/css/style.css (Dart Sass, compressed)"
  task :build do
    require "sass-embedded"
    entry = File.expand_path("_sass/blue.scss", __dir__)
    out   = File.expand_path("src/css/style.css", __dir__)

    result = Sass.compile(
      entry,
      load_paths: [File.expand_path("_sass", __dir__)],
      style: :compressed,
      silence_deprecations: %w[
        slash-div import global-builtin color-functions
        legacy-js-api strict-unary mixed-decls
      ]
    )

    File.write(out, result.css)
    puts "Wrote #{out} (#{result.css.bytesize} bytes)"
  end
end
```

## Change 3 — Bootstrap esbuild: package.json

**File:** `package.json` (new)

```json
{
  "name": "rakefire.io",
  "version": "1.0.0",
  "type": "module",
  "private": true,
  "scripts": {
    "esbuild": "node esbuild.config.js --minify",
    "esbuild-dev": "node esbuild.config.js --watch"
  },
  "devDependencies": {
    "esbuild": "^0.25.0",
    "glob": "^10.3.3",
    "postcss": "^8.4.29",
    "postcss-import": "^15.1.0",
    "postcss-load-config": "^4.0.1",
    "read-cache": "^1.0.0"
  }
}
```

After creating, run `npm install` to generate `package-lock.json`. Commit both.

## Change 4 — Bootstrap esbuild: esbuild.config.js

**File:** `esbuild.config.js` (new)

```javascript
import build from "./config/esbuild.defaults.js"

const esbuildOptions = {
  plugins: [],
  globOptions: {
    excludeFilter: /\.(dsd|lit)\.css$/
  }
}

build(esbuildOptions)
```

## Change 5 — Bootstrap esbuild: config/esbuild.defaults.js

**File:** `config/esbuild.defaults.js` (new)

This file is copy-paste from a working sibling repo. Run:

```bash
cp ~/github/www-rickychilcott-com/config/esbuild.defaults.js \
   ~/github/www-rakefire-io/config/esbuild.defaults.js
```

(rickychilcott has the same file, generated by `bridgetown new` — it's the standard Bridgetown 2.x esbuild defaults.)

## Change 6 — Bootstrap esbuild: frontend/ stub

**Files (new):**

`frontend/javascript/index.js`:

```javascript
// Top-level frontend JS entry. Add imports here as the site grows.
console.log("Rakefire frontend loaded");
```

`frontend/styles/index.css`:

```css
/* Top-level frontend CSS entry. */
```

These keep esbuild from erroring on an empty entry. The existing site CSS (`src/css/style.css` and the vendored CSS files in `src/css/`) and JS (vendored jQuery in `src/js/`) continue to load via `<link>` and `<script>` tags as today — esbuild is additive, not replacing them.

## Change 7 — Add htmlcompressor gem

**File:** `Gemfile`

Add after the existing `gem` lines:

```ruby
gem "htmlcompressor", "~> 0.4"
```

Then `bundle install`. Commit `Gemfile.lock`.

## Change 8 — _sass/blue.scss warning

**File:** `_sass/blue.scss`

Prepend at the very top of the file (before the existing first line):

```scss
// ⚠️ REFERENCE ONLY — DO NOT EDIT EXPECTING A REBUILD ⚠️
//
// src/css/style.css is the byte-exact output of Jekyll's libsass build,
// committed verbatim and served as-is. Editing this file does NOT change
// the deployed CSS. CI does not rebuild from _sass/.
//
// `rake css:build` will compile from these sources via Dart Sass, but the
// output will differ from the committed style.css due to Dart-vs-libsass
// behavioral differences in this old Bootstrap. Diff carefully before
// committing any rebuild.
```

## Change 9 — Create IndexNow key file

**File:** `src/d3edebe3-2774-4cd0-b3aa-780a8587c0a6.txt`

Contents:

```
d3edebe3-2774-4cd0-b3aa-780a8587c0a6
```

## Change 10 — IndexNow builder

**File:** `plugins/builders/indexnow.rb` (new)

```ruby
require "net/http"
require "json"
require "uri"
require "rexml/document"

class Builders::Indexnow < SiteBuilder
  INDEXNOW_KEY = "d3edebe3-2774-4cd0-b3aa-780a8587c0a6"
  INDEXNOW_API = "https://api.indexnow.org/indexnow"
  SITE_HOST = "https://www.rakefire.io"

  def build
    hook :site, :post_write do
      next unless should_run?

      urls = collect_urls_from_sitemap

      if urls.empty?
        Bridgetown.logger.info "IndexNow:", "No URLs to submit"
        next
      end

      submit_urls(urls)
    end
  end

  private

  def should_run?
    return true if ENV["INDEXNOW"] == "true"
    return true if Bridgetown.environment == "production"

    false
  end

  def collect_urls_from_sitemap
    sitemap_path = site.in_dest_dir("sitemap.xml")
    unless File.exist?(sitemap_path)
      Bridgetown.logger.warn "IndexNow:", "sitemap.xml not found at #{sitemap_path}"
      return []
    end

    doc = REXML::Document.new(File.read(sitemap_path))
    doc.elements.collect("urlset/url/loc") { |el| el.text }
  end

  def submit_urls(urls)
    Bridgetown.logger.info "IndexNow:", "Submitting #{urls.size} URL(s) to IndexNow"
    urls.each { |url| Bridgetown.logger.info "IndexNow:", "  → #{url}" }

    body = {
      host: URI(SITE_HOST).host,
      key: INDEXNOW_KEY,
      keyLocation: "#{SITE_HOST}/#{INDEXNOW_KEY}.txt",
      urlList: urls
    }

    uri = URI(INDEXNOW_API)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json; charset=utf-8"
    request.body = JSON.generate(body)

    response = http.request(request)

    case response.code.to_i
    when 200, 202
      Bridgetown.logger.info "IndexNow:", "Successfully submitted (HTTP #{response.code})"
    else
      Bridgetown.logger.warn "IndexNow:", "API returned HTTP #{response.code}: #{response.body}"
    end
  rescue => e
    Bridgetown.logger.error "IndexNow:", "Submission failed: #{e.class} - #{e.message}"
  end
end
```

`bridgetown-sitemap` is already in `config/initializers.rb` — generates `output/sitemap.xml` for this builder to read.

## Change 11 — HTML minifier builder

**File:** `plugins/builders/html_minifier.rb` (new)

```ruby
require "htmlcompressor"

class Builders::HTMLMinifier < SiteBuilder
  def build
    hook :site, :post_write do
      next if config[:watch]

      Bridgetown.logger.info "HTML Minifier:", "Compressing HTML files..."

      compressor = HtmlCompressor::Compressor.new(
        remove_comments: true,
        remove_multi_spaces: true,
        remove_intertag_spaces: false,
        preserve_line_breaks: false
      )

      html_files = Dir.glob(File.join(site.dest, "**", "*.html"))
      html_files.each do |file|
        content = File.read(file)
        compressed = compressor.compress(content)
        File.write(file, compressed)
      end

      Bridgetown.logger.info "HTML Minifier:", "Compressed #{html_files.size} HTML files"
    end
  end
end
```

## Change 12 — Update docs/gha-deploy-flow.md

The deck currently describes Rakefire as the "simplest" of the four sites with no Node toolchain. That's no longer true. Update slides:

- Triggers: add daily cron
- Environment setup: now includes Node 20, npm ci, esbuild
- Build step: now `bundle exec rake deploy` not `bundle exec bridgetown build`
- Add slides about esbuild + IndexNow + HTML minifier (mirror Stoked deck structure)
- "CSS comes from" slide: keep, but add the `_sass/` warning note

## Verify

```bash
cd ~/github/www-rakefire-io

# Esbuild scaffolding works
npm install
npm run esbuild
ls output/_bridgetown/static/    # expect bundled JS/CSS after build

# Full deploy chain
bundle exec rake deploy
# expect: clean → npm run esbuild → bridgetown build → HTML Minifier compresses N files

# IndexNow dry run
INDEXNOW=true bundle exec rake deploy
# expect: "Submitting N URL(s)" + "Successfully submitted"

# Sitemap exists
ls output/sitemap.xml
ls output/d3edebe3-2774-4cd0-b3aa-780a8587c0a6.txt
```

## Commit

```bash
git add .github/workflows/pages.yml \
        Rakefile \
        Gemfile Gemfile.lock \
        package.json package-lock.json \
        esbuild.config.js \
        config/esbuild.defaults.js \
        frontend/ \
        plugins/builders/ \
        src/d3edebe3-2774-4cd0-b3aa-780a8587c0a6.txt \
        _sass/blue.scss \
        docs/gha-deploy-flow.md
git commit -m "Align CI with sister sites: Ruby 4.0.3, esbuild, IndexNow, HTML minifier, daily cron"
```

## Out of scope (do not do)

- Do not add a CSS rebuild step to CI. The committed `src/css/style.css` is the source of truth.
- Do not migrate the vendored jQuery/Bootstrap JS in `src/js/` to esbuild. That's a separate refactor.
