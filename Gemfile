source "https://rubygems.org"

gem "bridgetown", "~> 2.1"
gem "bridgetown-feed", "~> 4.0"
gem "bridgetown-sitemap", "~> 3.0"
gem "bridgetown-seo-tag", "~> 7.0"

# SCSS compilation for src/css/style.scss when sources change.
# Used by `rake css:build`; runtime build uses the precompiled CSS.
gem "sass-embedded", "~> 1.0", require: false

# HTML parsing + markdown conversion for the markdown_for_agents builder.
gem "nokogiri", "~> 1.13"
gem "reverse_markdown", "~> 3.0"

gem "htmlcompressor", "~> 0.4"

group :test, :development do
  gem "puma", "~> 6.0"
end
