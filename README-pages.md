
## Creating a GitLab Pages site for your project

GitLab uses a static site publishing tool called GitLab pages
that allows us to publish reports of what happened during a
CI run.

Assuming you already have a `gitlab-ci.yml` file installed, you
just need to add steps to create a directory such as `public`
containing the static files you'd like to include in your GitLab
Pages site. For example, you could just put an
`public/index.html` file at the top of your
repository tree, with contents such as

    <html>
      <head>
        <title>Home</title>
      </head>
      <body>
        <h1>Hello World!</h1>
      </body>
    </html>

Next, you'd add a stage to your CI/CD spec to publish
the static site:

    steps:
        - ...
        - publish
    ...
    pages:
        stage: publish
        dependencies:
          - Test application
        image: $CI_REGISTRY_IMAGE
        artifacts:
            paths:
                - public

Then, on a successful build, you'll have an updated
site at, for example,
[https://ait-wae-2021.gitlab.io/web16/web16-app](
https://ait-wae-2021.gitlab.io/web16/web16-app).

That makes a pretty ugly site, however. To make something
slightly more sophisticated but still static, you can use
a gem such as Jekyll, developed by GitHub specifically for
its original Pages feature.

To use Jekyll, on your development machine, do a

    % gem install jekyll
    % cd ~/Projects/web16-app
    % jekyll new gitlab-pages

If you're using Ruby version 3, you'll need to add a line

    gem 'webrick'

to run an interactive server for development in the
`gitlab-pages/Gemfile` file. After that, run bundler and start
the jekyll server so you can see your templated site:

    % bundle install
    % jekyll s

Play around with the template to make it look like what you want.
Try copying in your coverage report, cucumber report, etc. and
link to them. Finally to set this up as part of CI/CD, add something
similar to this to the pages publishing step in `.gitlab-ci.yml`:

        script:
            - cp -r studentdb/coverage gitlab-pages/
            - cp cucumber-reports.html gitlab-pages/
            - cd gitlab-pages
            - gem install bundler
            - bundle install
            - bundle exec jekyll build -d ../public

Once your pipeline does a valid publish for the first time,
you'll end up with a static website under the `gitlab.io`
domain. In my case, since the repo is at
`ait-wae-2021/web16/web16-app`,
the Pages site is at 
[https://ait-wae-2021.gitlab.io/web16/web16-app/](https://ait-wae-2021.gitlab.io/web16/web16-app/).
