module.exports = {
  webpack: config => {
    // Fixes npm packages that depend on `fs` module
    node = {
      fs: 'empty',
      module: 'empty',
      net: 'empty'
    },
    {
      resolve: {
        fallback: {
          fs: false
        }
      }
    }

    return config
  },
  output: "standalone",
};
