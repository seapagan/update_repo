#!/usr/bin/env bash
# these will run as the default non-privileged user.

# install rbenv ruby version manager
export PATH="$HOME/.rbenv/bin:$PATH"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
# install dynamic bash extension
cd ~/.rbenv && src/configure && make -C src
# add the rbenv setup to our profile, only if it is not already there
if ! grep -qc 'rbenv init' /home/ubuntu/.bashrc ; then
  echo "## Adding rbenv to .bashrc ##"
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
fi
# run the above command locally so we can get rbenv to work on this provisioning shell
eval "$(rbenv init -)"
# set up .gemrc to avoid installing documentation for each gem...
echo "gem: --no-document" > ~/.gemrc
# install the required ruby version and set as default
rbenv install 2.4.0
rbenv global 2.4.0
gem update --system
gem update
gem install bundler

# install nvm  Node Version Manager and good version of node...
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 6.10.0
nvm use 6.10.0
npm install gulp -g

# install the required deps for Ruby...
cd /vagrant && bundle install
# install required Node deps for the website...
cd /vagrant/web && npm install 
