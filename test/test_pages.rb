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

  it "returns 404 for unknown pages" do
    expect(get("/this-page-does-not-exist/").status) == 404
  end
end
