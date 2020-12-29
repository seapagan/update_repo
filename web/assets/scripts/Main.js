// this will be the main Javascript file
import "../styles/styles.css";

if (module.hot) {
  module.hot.accept();
}

// return the version number of the latest released Gem
function getgemver() {
  // URL to the API...
  var APIurl = "https://rubygems.org/api/v1/gems/update_repo.json";
  jQuery.getJSON(APIurl, function (data) {
    jQuery("#version").text(data.version);
  });
}

// call the function to get the latest our published gem version
getgemver();
