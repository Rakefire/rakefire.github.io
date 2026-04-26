require "bridgetown"

# Compile _sass sources into src/css/style.css.
# Mirrors the Jekyll `css/style.scss` entry point + compressed output.
namespace :css do
  desc "Compile _sass/blue.scss to src/css/style.css (compressed)"
  task :build do
    require "sass-embedded"
    entry = File.expand_path("_sass/blue.scss", __dir__)
    out   = File.expand_path("src/css/style.css", __dir__)

    result = Sass.compile(
      entry,
      load_paths: [File.expand_path("_sass", __dir__)],
      style: :compressed,
      silence_deprecations: %w[
        slash-div import global-builtin color-functions
        legacy-js-api strict-unary mixed-decls
      ]
    )

    File.write(out, result.css)
    puts "Wrote #{out} (#{result.css.bytesize} bytes)"
  end
end
