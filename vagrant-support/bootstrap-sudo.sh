#!/usr/bin/env bash

# add PPA for latest Git version...
add-apt-repository ppa:git-core/ppa

# update package lists and upgrade the system...
apt-get update
apt-get -y full-upgrade

# install some required packages...
apt-get -y install git
# install Ruby compile dependencies...
apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

