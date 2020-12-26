const path = require("path");

const HtmlWebpackPlugin = require("html-webpack-plugin");
const HtmlWebpackPartialsPlugin = require("html-webpack-partials-plugin");

const postCSSPlugins = [
  require("postcss-import"),
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
  entry: "./assets/scripts/Main.js",
  output: {
    filename: "bundled.js",
    path: path.resolve(__dirname, "../docs"),
  },
  mode: "development",
  plugins: [
    new HtmlWebpackPlugin({
      title:
        "update_repo | Automate the update of multiple local Git repository clones",
    }),
    new HtmlWebpackPartialsPlugin(partialsList),
  ],
  watch: true,
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
