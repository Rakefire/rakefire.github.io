Bridgetown.configure do |config|
  url "https://www.rakefire.io"

  init :"bridgetown-feed"
  init :"bridgetown-sitemap"
  init :"bridgetown-seo-tag"
end
