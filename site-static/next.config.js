/**
 * @type {import('next').NextConfig}
 */
const nextConfig = {
  output: 'export',
 
  // Optional: Change links `/me` -> `/me/` and emit `/me.html` -> `/me/index.html`
  // trailingSlash: true,
 
  // Optional: Prevent automatic `/me` -> `/me/`, instead preserve `href`
  // skipTrailingSlashRedirect: true,
 
  // Optional: Change the output directory `out` -> `dist`
  // distDir: 'dist',
}
 
module.exports = nextConfig

// module.exports = {
//   webpack: config => {
//     // Fixes npm packages that depend on `fs` module
//     node = {
//       fs: 'empty',
//       module: 'empty',
//       net: 'empty'
//     },
//     {
//       resolve: {
//         fallback: {
//           fs: false
//         }
//       }
//     }

//     return config
//   },
//   output: "standalone",
// };
