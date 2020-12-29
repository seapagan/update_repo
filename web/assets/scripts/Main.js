// this will be the main Javascript file
import "../styles/styles.css";

if (module.hot) {
  module.hot.accept();
}

import Prism from "prismjs";
import "prismjs/components/prism-yaml.js";
import "prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js";

Prism.highlightAll();

// return the version number of the latest released Gem
function getgemver() {
  // URL to the API...
  var APIurl = "https://rubygems.org/api/v1/gems/update_repo.json";
  jQuery.getJSON(APIurl, function (data) {
    jQuery("#version").text(data.version);
  });
}

// call the function to get the our latest published gem version
getgemver();
