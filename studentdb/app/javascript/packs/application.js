
// This is the place to load any JavaScript libraries we want to be compiled by Webpack.

// Rails stuff

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// Font awesome, Material Design Bootstrap

import "@fortawesome/fontawesome-free/js/all"
import "mdb-ui-kit/js/mdb.min.js"

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
