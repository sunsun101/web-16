
// This is the place to load any JavaScript libraries we want to be compiled by Webpack.

// Rails stuff

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// Javascript: Font awesome, Material Design Bootstrap

require("@fortawesome/fontawesome-free/js/all.min.js")
require("mdb-ui-kit/js/mdb.min.js")
require("packs/mdb.js")
require("packs/projects.js")

// CSS: FA, MDB, our own custom CSS

import "@fortawesome/fontawesome-free/css/all.min.css"
import "mdb-ui-kit/css/mdb.min.css"
import "styles/application.scss"
import "slim-select/dist/slimselect.min.css"

// Images

const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
