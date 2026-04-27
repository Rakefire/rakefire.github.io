require "bridgetown"

Bridgetown.load_tasks

task default: :deploy

desc "Build the Bridgetown site for deployment"
task :deploy => [:clean, "frontend:build"] do
  Bridgetown::Commands::Build.start
end

desc "Runs the clean command"
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "npm run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "npm run esbuild-dev"
  rescue Interrupt
  end
end

# CSS rebuild task. The committed src/css/style.css is the byte-exact output
# from Jekyll's libsass build, kept verbatim so the Bridgetown deploy renders
# identically. If you edit _sass sources, run `rake css:build` — but note that
# Dart Sass (sass-embedded) emits a different stylesheet from this old Bootstrap
# than libsass did. Check the diff before committing.
namespace :css do
  desc "Compile _sass/blue.scss to src/css/style.css (Dart Sass, compressed)"
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
