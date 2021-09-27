
## Using Webpacker to compile your CSS

OK, so do you need to know about this topic? Maybe.

Let's say you want to use a couple CSS and JavaScript libraries in your project.

![MDB logo](https://mdbcdn.b-cdn.net/wp-content/uploads/2018/06/logo-mdb-jquery-small.png "MDB logo")

In my case, I like the look of Material Design, and I like the layout capabilities
of Boostrap. There is a company [MDBootstrap.com](https://mdboostrap.com) that
makes a stable and easy to use freemium integration of these two libraries so
I thought I'd give it a try.

<img src="https://i1.wp.com/blog.fontawesome.com/wp-content/uploads/2020/08/Proposed.png" width="80" alt="Fontawesome logo"/>

Also, just about every project needs elegant icons. One of the best icon libraries
is another freemimum product, [Font Awesome](https://fontawesome.com).

### Standard setup in Rails 6

The standard setup in Rails 6 is to have Webpacker manage your Javascript and have
the classic Rails assets pipeline manage your CSS.

That means Javascript libraries are imported in `app/javascript/packs`,
and CSS is stored in `app/assets/stylesheets`. In development mode, assets are loaded individually,
and Webpacker runs dynamically to compile your Javascript. You have two tags
in your application layout to tell Rails, Webpacker, and the assets pipeline about your
Javascript and CSS:

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

### Adding JS/CSS node libraries

This works fine until you want to set up production compilation of assets and packs for libraries
installed with yarn. For example, the simplest way to install MDB and FA is

    % yarn add mdb-ui-kit
    % yarn add @fortawesome/fontawesome-free

This puts the libraries under your `node_modules` directory.
Then, in `app/javascript/packs/application.js`, you can add the lines

    import "@fortawesome/fontawesome-free/js/all.min.js"
    import "mdb-ui-kit/js/mdb.min.js"

to get the Javascript parts of these libraries humming.  Then what? You need to
import `@fortawesome/fontawesome-free/css/all.min.css` and
`mdb-ui-kit/css/mdb.min.css` in the assets pipeline. I found that adding a SCCS file
in `app/assets/stylesheets/` with `@import` statements does the trick in development,
but it didn't work in production, at least out of the box with Capistrano's asset
precompilation.

### Getting Webpacker to build Javascript and CSS packs

I don't know if this is the best solution, but I did find that Webpacker has
the ability to pack CSS as well as Javascript. Amazingly, all you have to do
is, in `app/javascript/packs/application.js`, add lines such as

    import "@fortawesome/fontawesome-free/css/all.min.css"
    import "mdb-ui-kit/css/mdb.min.css"
    import "styles/application.scss"

That's CSS and Javascript imports right together in a Javascript file. Does it
make sense? No. Does it work? Yes. To tell Webpacker to pack your CSS as well as
your Javascript, you change the stylesheet tag in your application layout to

    <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>

Move all your CSS from `app/assets/stylesheets` to `app/javascript/styles`. I put all my
custom CSS in `app/javascript/packs/application.scss` so I only have one file to import
besides the library files.

Also, **remove** the line

    //= link_directory ../stylesheets .css

from `app/assets/config/manifest.js` so that the assets pipeline precompilation
doesn't try to build your CSS anymore.

### One more thing: MDB CSS syntax error

The last trouble I had, which was very confusing, was a syntax error in the MDB CSS file
that comes up when Webpacker tries to pack it with the postcss library.

I cannot explain this, but changing the postcss configuration file (`postcss.config.js` at the
top of the project tree) to the following.

    module.exports = {
      plugins: [
        require('postcss-import'),
        require('postcss-flexbugs-fixes'),
        require('postcss-preset-env')({
          autoprefixer: {
            flexbox: 'no-2009'
          },
          stage: 4
        })
      ]
    }

All of this is the default configuration except `stage: 4` rather than 3. Why does it fix the
syntax error? It has something to do with `calc()` operations (math/arithmetic in CSS) in the
MDB CSS. You'll see some discussion of this issue in GitHub's postcss project
pages. Other than that, it's a mystery.

### Bootstrap forms in MDB

Getting MDB form inputs to work correctly seems to need an extra bit of JavaScript code.
And for Rails, since views are loaded from Ajax calls, any code that needs to run when
a page/component is refreshed needs to be run in a `turbolinks:load` event handler (this
runs when the initial page resulting from a full HTTP request is done loading) *and*
in a `turbolinks:render` handler (this runs after the view has been loaded by Ajax after an
internal click. I added

    import "packs/mdb.js"

to `app/javascript/packs/application.js` and then added

    import * as mdb from "mdb-ui-kit/js/mdb.min.js"

    // Function to refresh input element style when necessary

    var mdbInputUpdate = function () {
      document.querySelectorAll('.form-outline').forEach((formOutline) => {
        new mdb.Input(formOutline).init();
      });
      document.querySelectorAll('.form-outline').forEach((formOutline) => {
        new mdb.Input(formOutline).update();
      });
    }

    document.addEventListener('turbolinks:load', () => {
      mdbInputUpdate();
    });

    document.addEventListener('turbolinks:render', () => {
      mdbInputUpdate();
    });

to `app/javascript/packs/mdb.js`. This got my form inputs with a `div.form-outline` wrapping them
to work correctly.

That's about it. Let me know if you have trouble!
