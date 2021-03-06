const currentTask = process.env.npm_lifecycle_event;
const path = require("path");
const webpack = require("webpack");

const HtmlWebpackPlugin = require("html-webpack-plugin");
const HtmlWebpackPartialsPlugin = require("html-webpack-partials-plugin");
const HtmlWebpackHarddiskPlugin = require("html-webpack-harddisk-plugin");
const ExtraWatchWebpackPlugin = require("extra-watch-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const fse = require("fs-extra");

const postCSSPlugins = [
  require("postcss-import"),
  require("postcss-mixins"),
  require("postcss-simple-vars"),
  require("postcss-nested"),
  require("autoprefixer"),
];

class RunAfterCompile {
  apply(compiler) {
    compiler.hooks.done.tap("Copy CNAME", function () {
      fse.copySync("./CNAME", "../docs/CNAME");
    });
  }
}

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

let cssConfig = {
  test: /\.css$/i,
  use: [
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
};

const pluginList = [
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
  new CleanWebpackPlugin(),
];

let config = {
  entry: "./assets/scripts/Main.js",
  output: {
    filename: "bundled.js",
    path: path.resolve(__dirname, "../docs"),
  },
  plugins: pluginList,
  module: {
    rules: [cssConfig],
  },
};

if (currentTask == "dev") {
  cssConfig.use.unshift("style-loader");
  config.devServer = {
    static: [path.resolve(__dirname, "../docs")],
    hot: true,
    port: 3000,
    dev: { writeToDisk: true },
  };
  config.mode = "development";
}

if (currentTask == "build") {
  config.module.rules.push({
    test: /\.js$/,
    exclude: /(node_modules)/,
    use: {
      loader: "babel-loader",
      options: {
        presets: ["@babel/preset-env"],
      },
    },
  });
  cssConfig.use.unshift(MiniCssExtractPlugin.loader);
  postCSSPlugins.push(
    require("cssnano")({
      preset: [
        "default",
        {
          discardComments: {
            removeAll: true,
          },
        },
      ],
    })
  );
  pluginList.push(
    new MiniCssExtractPlugin({ filename: "styles.[chunkhash].css" }),
    new RunAfterCompile()
  );
  config.output = {
    filename: "[name].[chunkhash].js",
    chunkFilename: "[name].[chunkhash].js",
    path: path.resolve(__dirname, "../docs"),
  };
  config.mode = "production";
  config.optimization = {
    splitChunks: { chunks: "all" },
    // minimizer: [
    //   new OptimizeCSSAssetsPlugin({
    //     // cssnano configuration
    //     cssProcessorPluginOptions: {
    //       preset: [
    //         "default",
    //         {
    //           discardComments: {
    //             removeAll: true,
    //           },
    //         },
    //       ],
    //     },
    //   }),
    // ],
  };
}

module.exports = config;
