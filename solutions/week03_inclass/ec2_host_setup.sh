#!/usr/bin/env bash
#
# Configure a Ubuntu 23.04 server to host a static site using nginx
# Requrements:
#  - Must be run on 'new' instance of an Ubuntu 23.04 server
#  - Must be run as root

set nounset

# Don't have interactive restart of services
# https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-for-ubuntu-debian/
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

declare -ra APP_PACKAGES=("git" "nginx" "pkg-config")
declare -r WEB_ROOT="/var/www/html"
declare -r WEB_CONF_FILE="/etc/nginx/sites-available/default"

################################################################################
# Package Setup
#
# Installs packages required for the application
# Globals:
#   APP_PACKAGES: An array of packages to install
################################################################################
function package_setup() {
  # update package list and upgrade packages
  apt-get update -y
  apt-get upgrade -y

  # Install packages
  apt-get install -y "${APP_PACKAGES[@]}"
}

################################################################################
# Web Setup
#
# Creates a test index.html file and restarts, and enables nginx.
# This assumes the default nginx configuration file is in use.
# Globals:
#   WEBROOT: the root directory for the web server
################################################################################
function web_setup() {

  # Create a test index.html file
  tee "${WEB_ROOT}/index.html" <<EOF >/dev/null
<html>
  <head>
    <title>ACIT 4640 Week 03</title>
  </head>
  <body>
    <h1>ACIT 4640 Week 03</h1>
    <p>This was generated using user_data and a setup script</p>
  </body>
</html>
EOF

  systemctl restart nginx
  systemctl enable nginx

}

package_setup
web_setup
