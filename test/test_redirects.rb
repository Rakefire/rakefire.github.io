require "minitest_helper"
require "csv"

class TestRedirects < Bridgetown::Test
  CSV.read(File.expand_path("../src/_data/redirects.csv", __dir__), headers: true).each do |row|
    it "redirects /#{row["from"]}/ to #{row["to"]}" do
      html get("/#{row["from"]}/")
      expect(last_response.status) == 200
      expect(document.query_selector("meta[http-equiv=refresh]")["content"]) == "0; url=#{row["to"]}"
      expect(document.query_selector("link[rel=canonical]")["href"]) == row["to"]
      expect(meta("robots")) == "noindex"
    end
  end
end
