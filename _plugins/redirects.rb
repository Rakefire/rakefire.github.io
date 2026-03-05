# Generates redirect pages from _data/redirects.csv
# Each row creates a page with redirect_to frontmatter,
# which jekyll-redirect-from uses to generate HTML redirect pages.

module RedirectPages
  class RedirectPage < Jekyll::Page
    def initialize(site, from, to)
      @site = site
      @base = site.source

      from = "/#{from}" unless from.start_with?("/")

      @dir = from
      @name = "index.html"

      self.process(@name)
      self.data = {
        "redirect_to" => to,
        "sitemap" => false,
        "layout" => nil
      }
      self.content = ""
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      redirects = site.data["redirects"]
      return unless redirects

      redirects.each do |redirect|
        from = redirect["from"]
        to = redirect["to"]

        next if from.nil? || from.empty? || to.nil? || to.empty?

        site.pages << RedirectPage.new(site, from, to)
        Jekyll.logger.info "Redirect:", "#{from} -> #{to}"
      end
    end
  end
end
