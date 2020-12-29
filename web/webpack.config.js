const path = require("path");
const webpack = require("webpack");

const HtmlWebpackPlugin = require("html-webpack-plugin");
const HtmlWebpackPartialsPlugin = require("html-webpack-partials-plugin");
const HtmlWebpackHarddiskPlugin = require("html-webpack-harddisk-plugin");
const ExtraWatchWebpackPlugin = require("extra-watch-webpack-plugin");

const postCSSPlugins = [
  require("postcss-import"),
  require("postcss-mixins"),
  require("postcss-simple-vars"),
  require("postcss-nested"),
  require("autoprefixer"),
];

const partialsList = [
  { path: path.join(__dirname, "./partials/_links.html"), location: "head" },
  { path: path.join(__dirname, "partials/_navbar.html") },
  { path: path.join(__dirname, "partials/_about.html") },
  { path: path.join(__dirname, "partials/_installation.html") },
  { path: path.join(__dirname, "partials/_usage.html") },
  { path: path.join(__dirname, "partials/_configuration.html") },
  { path: path.join(__dirname, "partials/_contribute.html") },
  { path: path.join(__dirname, "partials/_license.html") },
  { path: path.join(__dirname, "partials/_footer.html") },
];

module.exports = {
  resolve: {
    alias: {
      // use the raw jquery instead of the precompiled minimised
      jquery: "jquery/src/jquery",
    },
  },
  entry: "./assets/scripts/Main.js",
  output: {
    filename: "bundled.js",
    path: path.resolve(__dirname, "../docs"),
  },
  devServer: {
    static: [path.resolve(__dirname, "../docs")],
    hot: true,
    port: 3000,
  },
  mode: "development",
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
    new ExtraWatchWebpackPlugin({
      files: ["./partials/*.html"],
    }),
    new HtmlWebpackPlugin({
      title:
        "update_repo | Automate the update of multiple local Git repository clones",
      alwaysWriteToDisk: true,
    }),
    new HtmlWebpackPartialsPlugin(partialsList),
    new HtmlWebpackHarddiskPlugin(),
  ],
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [
          "style-loader",
          "css-loader?url=false",
          {
            loader: "postcss-loader",
            options: {
              postcssOptions: {
                plugins: postCSSPlugins,
              },
            },
          },
        ],
      },
    ],
  },
};
