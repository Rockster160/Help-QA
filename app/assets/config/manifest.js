//= link_tree ../images
//= link_directory ../javascripts .js
//= link_directory ../stylesheets .css

// Sprockets 4 requires non-JS/CSS assets referenced from views to be linked
// explicitly. These two are .erb templates, so link_tree above does not pick
// up their compiled logical paths.
//= link favicon/manifest.json
//= link favicon/browserconfig.xml
