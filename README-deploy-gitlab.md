
## Deploying to production from GitLab with Capistrano

To deploy our application to production from CI/CD, we basically need

1. A Docker image with the right version of Ruby and Ruby Gems.
2. Bundler and a bundle install of the Gems needed for deployment
   (Capistrano and friends).
3. A SSH key allowing the process running our GitLab CI to log in
   to the server as the `deploy` user.
4. A `deploy` stage in `.gitlab-ci.yml` to actually do the deployment.
   This should be manually triggered by an operator rather than
   automatic.

Let's see how to set these things up. After a successful test, we should
have our workspace configured with an up-to-date bundle ready to deploy.

For the SSH key, we need to create a new one (once only). Use an empty
passphrase:

    % ssh-keygen -t ed25519
    Generating public/private ed25519 key pair.
    Enter file in which to save the key (/home/mdailey/.ssh/id_ed25519): gitlab_ed25519
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in gitlab_ed25519
    Your public key has been saved in gitlab_ed25519.pub
    The key fingerprint is:
    ...

The public key goes on the production server.
Add the contents of `gitlab_ed25519.pub` to the `~deploy/.ssh/authorized_keys` file on your
server.

The private key must be uploaded to GitLab and used during the deployment. Here we have
to trust that the GitLab admins won't steal our deployment key!
In GitLab, go to Settings -> CI/CD -> Variables, click on "Add variable", choose type
"File", turn off "Protect variable", use a key such as
`DEPLOY_SSH_PRIV_KEY`, and use the contents of the private key file (`-----BEGIN OPENSSH PRI...`)
for the Value.

**Important: make sure you add a trailing newline at the end of the file (there should be a blank line at the end
of the file) when you enter it as the Value of the file variable. If you miss this, you will get a mysterious error
from `ssh-add` that the format of the key file is invalid.**

Finally, add the deploy stage to your `.gitlab-ci.yml` file:

    stages:
        ...
        - deploy
        ...
    Deploy to production:
        stage: deploy
        when: manual
       dependencies:
            - Test application
        image: $CI_REGISTRY_IMAGE
        script:
            - cd studentdb
            - mkdir -p /root/.ssh
            - cp $DEPLOY_SSH_PRIV_KEY /root/.ssh/gitlab_ed25519
            - chmod 600 /root/.ssh/gitlab_ed25519
            - eval $(ssh-agent)
            - ssh-add /root/.ssh/gitlab_ed25519
            - bundle exec cap production deploy

This, of course, requires that the Capistrano gem is installed.
But this is an isolated execution of the Alpine Ruby image, so
it won't remember your bundle from the build step unless you
created it in the working directory. Therefore, before the
`bundle install` in the build/test step, make sure you tell
Bundler to use a local directory for the bundle, for example

    ...
    Test application:
        ...
        script:
            - cd studentdb
            - bundle config set --local path '.bundle'
            ...

That should do it! Let me know if any trouble.
