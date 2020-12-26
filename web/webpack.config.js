const { clear } = require("console");
const path = require("path");

module.exports = {
  entry: "./assets/scripts/Main.js",
  output: {
    filename: "bundled.js",
    path: path.resolve(__dirname, "../docs"),
  },
  mode: "development",
  watch: true,
};
