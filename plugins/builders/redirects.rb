class Builders::Redirects < SiteBuilder
  REDIRECT_TEMPLATE = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>Redirecting&hellip;</title>
      <link rel="canonical" href="%<to>s">
      <meta http-equiv="refresh" content="0; url=%<to>s">
      <meta name="robots" content="noindex">
    </head>
    <body>
      <h1>Redirecting&hellip;</h1>
      <a href="%<to>s">Click here if you are not redirected.</a>
      <script>location.replace("%<to>s");</script>
    </body>
    </html>
  HTML

  def build
    generator do
      next unless site.data.redirects

      site.data.redirects.each do |redirect|
        from = redirect[:from] || redirect["from"]
        to   = redirect[:to]   || redirect["to"]
        next if from.to_s.empty? || to.to_s.empty?

        from = "/#{from}" unless from.start_with?("/")

        page = Bridgetown::GeneratedPage.new(site, site.source, from, "index.html")
        page.content = format(REDIRECT_TEMPLATE, to: to)
        page.data[:layout]  = nil
        page.data[:sitemap] = false
        site.generated_pages << page
      end
    end
  end
end
