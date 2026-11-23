ENV["MT_NO_EXPECTATIONS"] = "true"
require "minitest/autorun"
require "bridgetown/test"

OUTPUT = File.expand_path("../output", __dir__)
abort "No build found. Run `bin/bridgetown build` (or `bundle exec rake deploy`) first." unless File.exist?("#{OUTPUT}/index.html")

# ponytail: no server/ dir on this static site, so use Bridgetown's default Roda app (serves output/)
class RodaApp < Roda
  plugin :bridgetown_server
  route(&:bridgetown)
end

class Bridgetown::Test
  SITE_URL = "https://www.rakefire.io"

  # Every built HTML page except redirect stubs and vendored font demos.
  def self.html_pages
    Dir.glob("**/index.html", base: OUTPUT)
      .reject { |f| f.start_with?("fonts/") || File.read("#{OUTPUT}/#{f}").include?('http-equiv="refresh"') }
      .map { |f| "/#{f.delete_suffix("index.html")}" }
      .sort
  end

  def meta(name) = document.query_selector("meta[name='#{name}'], meta[property='#{name}']")&.[]("content")
end
