import build from "./config/esbuild.defaults.js"

const esbuildOptions = {
  plugins: [],
  globOptions: {
    excludeFilter: /\.(dsd|lit)\.css$/
  }
}

build(esbuildOptions)
