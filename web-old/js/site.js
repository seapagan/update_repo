// Site-specific Javascript

// return the version number of the latest released Gem
function getgemver () {
  // URL to the API...
  var APIurl = 'https://rubygems.org/api/v1/versions/update_repo/latest.json?callback=?';
  jQuery.getJSON( APIurl, function( data ) {
    console.log(data);
    jQuery("#version").text(data.version);
  });
}

jQuery(document).ready(function() {
  getgemver();
});
