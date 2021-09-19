
# GitLab Runner installation in CSIM

This is a list of instructions for configuring a GitLab runner for CI/CD
in CSIM. The main trouble is dealing with the proxy server. WAE students
don't need to follow these instructions unless you want to make your own
runner, perhaps to improve runtime performance.

## Install packages

    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
    sudo mkdir /var/lib/gitlab-runner
    sudo apt install cntlm docker.io plymouth plymouth-label

## Register a runner

    gitlab-runner register --url https://gitlab.com/ --registration-token jxDu-NN1c9JVFtxosfrD --locked=false

## Edit GitLab runner configuration

    vi /etc/gitlab-runner/config.toml 

Fill in `config.toml` with contents:

    concurrent = 1
    check_interval = 0

    [[runners]]
      name = "AIT WAE GitLab Runner"
      url = "https://gitlab.com/"
      token = "rVVNS1wbNAzVyEZKMQYn"
      executor = "docker"
      pre_clone_script = "git config --global http.proxy $HTTP_PROXY; git config --global https.proxy $HTTPS_PROXY"
      environment = ["https_proxy=http://172.17.0.1:3128", "http_proxy=http://172.17.0.1:3128", "HTTPS_PROXY=172.17.0.1:3128", "HTTP_PROXY=172.17.0.1:3128"]
      [runners.docker]
        tls_verify = false
        image = "ubuntu:20.04"
        privileged = true
        disable_cache = false
        volumes = ["/certs/client", "/cache", "/etc/docker/certs.d:/etc/docker/certs.d:ro"]
        shm_size = 0
        disable_entrypoint_overwrite = false
        oom_kill_disable = false
      [runners.cache]

## Modify docker group membership and test that gitlab-runner can run docker

    sudo usermod -aG docker gitlab-runner
    sudo usermod -aG docker mdailey
    sudo -u gitlab-runner -H docker info

## Get the IP address of the bridge on the docker0 network (172.17.0.1 usually)

    ip -4 -oneline addr show dev docker0

## Use the IP address from previous step to set up proxy for docker

    sudo vi /etc/cntlm.conf 

Edit `cntlm.conf` to have contents

    Proxy  192.41.170.23:3128
    Listen 172.17.0.1:3128

## Set proxy for gitlab runner

    vi /etc/systemd/system/gitlab-runner.service.d/http-proxy.conf

Edit `http-proxy.conf` to have contents

    [Service]
    Environment="HTTP_PROXY=http://172.17.0.1:3128/"
    Environment="HTTPS_PROXY=http://172.17.0.1:3128/"

## Set proxy for docker

    vi /lib/systemd/system/docker.service.d/http-proxy.conf

Contents of `http-proxy.conf` for Docker:

    [Service]
    Environment="HTTP_PROXY=http://172.17.0.1:3128/"
    Environment="HTTPS_PROXY=http://172.17.0.1:3128/"
    Environment="NO_PROXY=docker:2375,docker:2376"

We also need to set up the root user's docker configuration for
access to DockerHub:

    vi /root/.docker/config.json

The `config.json` file should look like:

    {
      "auths": {
        "https://index.docker.io/v1/": {
          "auth": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      },
      "proxies": {
        "default": {
          "httpProxy": "http://192.41.170.23:3128",
          "httpsProxy": "http://192.41.170.23:3128",
          "noProxy": "docker:2375,docker:2376"
        }
      }
    }

## Restart services

    systemctl daemon-reload
    sudo systemctl restart gitlab-runner.service 
    sudo systemctl restart cntlm
    sudo systemctl restart docker.service

## Verify everything's working

    systemctl show --property=Environment gitlab-runner
    systemctl show --property=Environment docker
    systemctl show --property=Environment cntlm
    docker info
    su gitlab-runner -c docker info
    docker run --privileged --name some-docker docker:dind

## Get CNTLM proxy to wait for Docker interface

One problem with the above configuration is that CNTLM will by
default run before Docker has completed it startup, and the
`docker0` interface (172.17.0.1) will not be available when
CNTLM starts, so it will halt.

To counter this, we can first of all tell systemd not to start
CNTLM until after docker, and also tell it to keep trying with
some interval such as 10 seconds.

    vi /etc/systemd/system/cntlm.service

Include contents below. Some may be redundant (they are from systemd's
SysV-init-to-systemd conversion program).

    [Unit]
    SourcePath=/etc/init.d/cntlm
    Description=Authenticating HTTP accelerator for NTLM secured proxies
    Before=multi-user.target
    Before=graphical.target
    After=remote-fs.target
    After=time-sync.target
    After=network-online.target
    Wants=network-online.target
    Wants=docker.service
    StartLimitInterval=600
    StartLimitBurst=60

    [Service]
    Type=forking
    Restart=always
    RestartSec=10
    TimeoutSec=5min
    IgnoreSIGPIPE=no
    KillMode=process
    GuessMainPID=no
    RemainAfterExit=yes
    SuccessExitStatus=5 6
    ExecStart=/etc/init.d/cntlm start
    ExecStop=/etc/init.d/cntlm stop
    ExecReload=/etc/init.d/cntlm reload

    [Install]
    WantedBy=multi-user.target

That's it! Test that it works on a reboot.
