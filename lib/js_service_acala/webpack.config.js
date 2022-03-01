const path = require("path");
const webpack = require("webpack");

const config = {
  entry: "./src/index.ts",
  output: {
    publicPath: path.resolve(__dirname, ""),
    path: path.resolve(__dirname, "dist"),
    filename: "main.js",
  },
  resolve: {
    extensions: [".ts", ".js", ".mjs", ".json", ".cjs"],
    fallback: { crypto: require.resolve("crypto-browserify"), stream: require.resolve("stream-browserify") },
  },
  plugins: [
    new webpack.ProvidePlugin({
      process: "process/browser.js",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: "babel-loader",
      },
      {
        test: /\.mjs$/,
        include: /node_modules/,
        type: "javascript/auto",
      },
      {
        test: /\.cjs$/,
        include: /node_modules/,
        use: "babel-loader",
      },
      {
        test: /\.js$/,
        include: /node_modules/,
        use: "babel-loader",
      },
    ],
  },
};

module.exports = config;
