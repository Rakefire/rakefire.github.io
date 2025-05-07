class CloudannonRedirectsGenerate
  def initialize(site)
    @site = site
  end

  def output!
    FileUtils.mkdir_p(".cloudcannon")
    File.write(".cloudcannon/redirects.json", JSON.pretty_generate(output))
  end

  private

  def redirects = @site.data.dig("redirects")

  def output
    {
      routes: generated_cloudcannon_redirects
    }
  end

  def generated_cloudcannon_redirects
    redirects.map do |redirect|
      from, to, status = redirect.values_at("from", "to", "status")

      next if from.empty? || to.empty?

      status ||= 302
      status = status.to_i

      from = "/#{from}" unless from.start_with?("/")

      puts "Redirecting #{from} to #{to} with status #{status}"

      {
        from: from,
        to: to,
        status: status
      }
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  CloudannonRedirectsGenerate.new(site).output!
end
