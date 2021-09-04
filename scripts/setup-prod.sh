#!/bin/bash

# Sample script for setting up a production server for a Rails
# application.

# Assumptions: you are an admin user with sudo privileges on the
# production server, DNS and external access to the server's port
# 80 and 443 is already in place, and you've set your account on
# the server with SSH access to the project Git repository already.

set -e

# Some variables that can be changed

APP="studentdb"                 # A subdir in your Git repo
PROD_DB="studentdb"             # Any database name you like
DEPLOY_USER="deploy"            # The user who will run your Rails app
DB_USER="studentdb"             # The database user to be created
TIMEZONE="Asia/Bangkok"         # Timezone the server will use
RUBY_VERSION="3.0.2"            # Version of ruby to install with rbenv
SERVER="web16.cs.ait.ac.th"     # Your production server hostname

# Move to project top-level directory

cd "`dirname $0`/.."

# Set system time zone if needed

echo "Checking time zone..."
timedatectl | grep "Time zone: $TIMEZONE" > /dev/null || {
  sudo timedatectl set-timezone $TIMEZONE
}

# Install Ubuntu packages

echo "Installing packages..."
sudo apt-get install -y build-essential libpq-dev libreadline-dev \
    libssl-dev zlib1g-dev libyaml-dev git software-properties-common \
    curl apache2 postgresql libcurl4-openssl-dev apache2-dev libapr1-dev \
    libaprutil1-dev python > /dev/null

# Put database.yml in $DEPLOY_USER user's shared config directory if needed

echo "Checking production database config..."
test -f /home/$DEPLOY_USER/$APP/shared/config/database.yml || {
  echo "No database.yml config"
  echo -n "Enter a new owner password for database $PROD_DB: "
  read -s password
  sudo mkdir -p /home/$DEPLOY_USER/$APP/shared/config
  cat > /tmp/tmpdbconfig.yml <<EOF
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost
  database: $PROD_DB
  username: $DB_USER
  password: $password
EOF
  sudo mv /tmp/tmpdbconfig.yml /home/$DEPLOY_USER/$APP/shared/config/database.yml
  sudo chown -R $DEPLOY_USER.$DEPLOY_USER /home/$DEPLOY_USER
  echo
}

# Set up NodeJS and yarn

echo "Checking NodeJS and yarn installation..."
which node > /dev/null || {
  echo "NodeJS not installed. Installing..."
  curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt-get install -y nodejs
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install -y yarn
}
echo "Configuring yarn and npm for proxy server..."
sudo su $DEPLOY_USER -c "yarn config set 'https-proxy' 'http://192.41.170.23:3128'" > /dev/null
sudo su $DEPLOY_USER -c "npm config set proxy 'http://192.41.170.23:3128'" > /dev/null

# Set up database user and database

echo "Checking database configuration..."
psql postgres -c "" > /dev/null 2>&1 || sudo su postgres -c "createuser -s $USER"
psql $PROD_DB -c "" > /dev/null 2>&1 || {
  createdb $PROD_DB
}
dbconfig="`sudo cat /home/$DEPLOY_USER/$APP/shared/config/database.yml`"
dbpassword=`echo $dbconfig | grep password | sed 's/^.*password: //' | sed 's/ .*$//'`
PGPASSWORD="$dbpassword" psql -h localhost -U $DB_USER $PROD_DB -c "" > /dev/null 2>&1 || {
  cmd="CREATE USER $DB_USER WITH PASSWORD '$dbpassword';"
  psql postgres -c "$cmd" > /dev/null
}
PGPASSWORD="$dbpassword" psql -h localhost -U $DB_USER $PROD_DB -c "" || {
  echo "Could not configure database!"
  exit 1
}

# Install rbenv for admin user if needed

echo "Checking rbenv installation..."
grep rbenv $HOME/.bashrc > /dev/null || {
  echo "Configure rbenv"
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  mkdir -p ~/.rbenv/plugins
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source ~/.bashrc
}

# Install the specified ruby version for the admin user if needed

rbenv global $RUBY_VERSION > /dev/null || {
  echo "Need to install ruby $RUBY_VERSION"
  rbenv install $RUBY_VERSION
}
rbenv global $RUBY_VERSION

# Set up rbenv for the deploy user:
#   The actual rbenv install is through Capistrano, not this script!
#   So we only need to set up the bash environment here.

grep rbenv /home/$DEPLOY_USER/.bashrc > /dev/null || {
  sudo su -c "echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> /home/$DEPLOY_USER/.bashrc"
  sudo su -c "echo 'export PATH=\"\$HOME/.rbenv/plugins/ruby-build/bin:\$PATH\"' >> /home/$DEPLOY_USER/.bashrc"
  sudo su -c "echo 'eval \"\$(rbenv init -)\"' >> /home/$DEPLOY_USER/.bashrc"
  sudo su -c "echo 'rbenv global $RUBY_VERSION' >> /home/$DEPLOY_USER/.bashrc"
}

# Set up git proxying for gitlab.com

if [ ! -f /home/$DEPLOY_USER/.ssh/config ] ; then
  cat > /tmp/ssh-config <<EOF
Host gitlab.com
  ProxyCommand ssh \${BAZOOKA_USER}@bazooka.cs.ait.ac.th nc %h %p
  ForwardAgent yes
EOF
  sudo mv /tmp/ssh-config /home/$DEPLOY_USER/.ssh/config
  sudo chown -R $DEPLOY_USER.$DEPLOY_USER /home/deploy/.ssh
fi

# Set up application server (puma)

echo "Setting up puma service"
sudo mkdir -p /home/$DEPLOY_USER/$APP/shared/tmp/sockets
sudo chown $DEPLOY_USER.$DEPLOY_USER /home/$DEPLOY_USER/$APP/shared/tmp
sudo chown $DEPLOY_USER.$DEPLOY_USER /home/$DEPLOY_USER/$APP/shared/tmp/sockets
sudo cp $APP/config/puma.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/puma.service
sudo systemctl daemon-reload
sudo systemctl enable puma.service
sudo systemctl start puma.service

# Set up Apache

sudo a2enmod proxy > /dev/null
sudo a2enmod proxy_http > /dev/null
sudo a2enmod ssl > /dev/null

# SSL

echo "Checking SSL configuration..."
sudo stat /etc/letsencrypt/live/$SERVER/fullchain.pem > /dev/null || {
  sudo systemctl stop apache2
  sudo HTTPS_PROXY=$https_proxy certbot certonly
  sudo systemctl start apache2
}

cat > /tmp/apacheconfig.txt <<EOF
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    ServerName $SERVER
    DocumentRoot /home/$DEPLOY_USER/$APP/current/public
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$SERVER/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$SERVER/privkey.pem
    <Directory /home/$DEPLOY_USER/$APP/current/public>
      AllowOverride all
      Options -MultiViews
      Require all granted
    </Directory>
    <Location /assets>
      ProxyPass !
    </Location>
    <Location /packs>
      ProxyPass !
    </Location>
    <Location /system>
      ProxyPass !
    </Location>
    ProxyPass / unix:///home/$DEPLOY_USER/$APP/shared/tmp/sockets/puma.sock|http://localhost/
    ProxyPassReverse / unix:///home/$DEPLOY_USER/$APP/shared/tmp/puma.sock|http://localhost/
  </VirtualHost>
</IfModule>
EOF
sudo mv /tmp/apacheconfig.txt /etc/apache2/sites-available/${APP}-ssl.conf

# HTTP

cat > /tmp/apacheconfig.txt <<EOF
<VirtualHost *:80>
  ServerName $SERVER
  Redirect permanent / https://$SERVER/
</VirtualHost>
EOF
sudo mv /tmp/apacheconfig.txt /etc/apache2/sites-available/$APP.conf
sudo a2dissite 000-default > /dev/null
sudo a2dissite default-ssl > /dev/null
sudo a2ensite $APP > /dev/null
sudo a2ensite ${APP}-ssl > /dev/null
sudo systemctl restart apache2

echo "Successful setup!"

