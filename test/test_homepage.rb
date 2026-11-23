require "minitest_helper"

class TestHomepage < Bridgetown::Test
  before { html get("/") }

  it "renders successfully" do
    expect(last_response.status) == 200
    expect(document.query_selector("html")["lang"]) == "en"
  end

  it "has the site title and description" do
    expect(document.query_selector("title").text) == "Rakefire | Ruby on Rails Web Application Development"
    expect(meta("description")).include? "Ruby on Rails agency and product studio"
  end

  it "has social sharing tags pointing at the canonical URL" do
    expect(meta("og:url")) == "#{SITE_URL}/"
    expect(meta("og:image")) == "#{SITE_URL}/images/rakefire_logo.png"
    expect(meta("twitter:card")) == "summary"
  end

  it "is indexable" do
    expect(meta("robots").to_s).exclude? "noindex"
  end

  it "has every section the nav links to" do
    targets = document.query_selector_all("#navbar a").map { _1["href"].split("#").last }
    expect(targets) == %w[home products work services about contact]
    targets.each { expect(document.query_selector("section##{_1}")).not_nil? }
  end

  it "has exactly one h1" do
    expect(document.query_selector_all("h1").size) == 1
  end

  it "links to both products" do
    hrefs = document.query_selector_all("#products a").map { _1["href"] }
    expect(hrefs).include? "https://www.causey.app/"
    expect(hrefs).include? "https://get.stokedhq.com/"
  end

  it "shows client work" do
    expect(document.query_selector_all("#work h3").to_a).not_empty?
  end

  it "has a contact email" do
    expect(document.query_selector("a[href='mailto:contact@rakefire.io']")).not_nil?
  end

  it "loads Plausible analytics" do
    expect(document.query_selector("script[src^='https://plausible.io/js/pa-']")).not_nil?
  end

  it "links to its markdown twin" do
    expect(document.query_selector("link[rel=alternate][type='text/markdown']")["href"]) == "/index.md"
  end
end
