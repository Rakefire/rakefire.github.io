require "minitest_helper"
require "digest"
require "rexml/document"

# robots, sitemap, feed, IndexNow, llms.txt, agent skills, api-catalog
class TestMachineReadable < Bridgetown::Test
  def sitemap_urls
    REXML::Document.new(get("/sitemap.xml").body).elements.collect("urlset/url/loc", &:text)
  end

  it "serves the custom domain CNAME" do
    expect(get("/CNAME").body.strip) == "www.rakefire.io"
  end

  it "allows crawling and points robots at the sitemap" do
    body = get("/robots.txt").body
    expect(body).include? "Allow: /"
    expect(body).include? "Sitemap: #{SITE_URL}/sitemap.xml"
  end

  it "lists every indexable page in the sitemap and nothing else" do
    indexable = self.class.html_pages.reject { html(get(_1)) && meta("robots").to_s.include?("noindex") }
    expect(sitemap_urls.sort) == indexable.map { "#{SITE_URL}#{_1}" }.sort
  end

  it "keeps redirect stubs out of the sitemap" do
    expect(sitemap_urls.grep(%r{/(ricky|stoked|causey)/})).empty?
  end

  it "has a parseable Atom feed" do
    feed = REXML::Document.new(get("/feed.xml").body)
    expect(feed.root.name) == "feed"
  end

  it "serves the IndexNow key file" do
    key = File.read(File.expand_path("../.github/workflows/pages.yml", __dir__))[/INDEXNOW_KEY: (\S+)/, 1]
    expect(get("/#{key}.txt").body.strip) == key
  end

  it "serves llms.txt with links that resolve" do
    body = get("/llms.txt").body
    expect(body).include? "# Rakefire"
    local = body.scan(%r{\]\((/[^)]+)\)}).flatten
    expect(local).not_empty?
    local.each { expect(get(_1).ok?).true?(_1) }
  end

  describe "agent skills" do
    let(:index) { JSON.parse(get("/.well-known/agent-skills/index.json").body) }

    it "lists every skill in _data/agent_skills.yml" do
      expected = YAML.load_file(File.expand_path("../src/_data/agent_skills.yml", __dir__))["skills"].map { _1["name"] }
      expect(index["skills"].map { _1["name"] }) == expected
    end

    it "publishes SKILL.md files whose digests match" do
      index["skills"].each do |skill|
        res = get(skill["url"])
        expect(res.ok?).true?(skill["url"])
        expect(skill["digest"]) == "sha256:#{Digest::SHA256.hexdigest(res.body)}"
      end
    end
  end

  it "has an api-catalog linkset pointing at the agent skills index" do
    catalog = JSON.parse(get("/.well-known/api-catalog").body)
    hrefs = catalog["linkset"].flat_map { _1["service-doc"] }.map { _1["href"] }
    expect(hrefs).include? "#{SITE_URL}/.well-known/agent-skills/index.json"
  end
end
