require "minitest_helper"

class TestPages < Bridgetown::Test
  html_pages.each do |path|
    describe path do
      before { html get(path) }

      it "renders with a title, description and og:url" do
        expect(last_response.status) == 200
        expect(document.query_selector("title").text).not_empty?
        expect(meta("description").to_s).not_empty?
        expect(meta("og:url")) == "#{SITE_URL}#{path}"
        expect(document.query_selector("link[rel=canonical]")["href"]) == "#{SITE_URL}#{path}"
      end

      it "has exactly one h1" do
        expect(document.query_selector_all("h1").size) == 1
      end

      it "gives every image alt text" do
        expect(document.query_selector_all("img:not([alt])").to_a).empty?
      end

      it "has no broken internal links or assets" do
        broken = document.query_selector_all("a[href], link[href], script[src], img[src]")
          .map { _1["href"] || _1["src"] }
          .reject { _1.match?(%r{\A(https?:|//|mailto:|tel:|#|data:|javascript:)}) }
          .map { URI.join("http://x#{path}", _1).path }
          .uniq
          .reject { get(_1).ok? }
        expect(broken).empty?
      end

      it "has a markdown twin" do
        expect(get("#{path}index.md").ok?).true?
      end
    end
  end

  describe "/presentations/ilead-2017/" do
    it "offers the PDF download" do
      html get("/presentations/ilead-2017/")
      pdf = document.query_selector("a[download]")["href"]
      expect(get(pdf).ok?).true?
    end
  end

  describe "/map-demo/" do
    it "is kept out of search engines" do
      html get("/map-demo/")
      expect(meta("robots")).include? "noindex"
    end
  end

  it "gives every page a unique title and description" do
    heads = self.class.html_pages.map { html(get(_1)) && [document.query_selector("title").text, meta("description")] }
    expect(heads.map(&:first).uniq.size) == heads.size
    expect(heads.map(&:last).uniq.size) == heads.size
  end

  # GitHub Pages serves output/404.html (with a 404 status) for any missing URL
  describe "/404.html" do
    before { html get("/404.html") }

    it "is branded, noindex, and kept out of the sitemap" do
      expect(last_response.status) == 200
      expect(document.query_selector("h1").text).include? "smoke"
      expect(meta("robots")) == "noindex"
      expect(get("/sitemap.xml").body).exclude? "404"
    end

    it "only uses root-relative or absolute URLs (it's served at arbitrary depths)" do
      relative = document.query_selector_all("a[href], link[href], script[src], img[src]")
        .map { _1["href"] || _1["src"] }
        .reject { _1.match?(%r{\A(/|https?:|mailto:|tel:|#)}) }
      expect(relative).empty?
    end

    it "links somewhere that works" do
      document.query_selector_all("#not-found a").each { expect(get(_1["href"].split("#").first).ok?).true?(_1["href"]) }
    end
  end
end
