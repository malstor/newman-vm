#!/usr/bin/env bash

#Try doing this java-repo thing here ...
pushd provision
. java-repo.sh
popd

printf "Attempting to create user & group \e[0;36m'vagrant'\e[0m\n"
sudo useradd -ms /bin/bash vagrant && sudo adduser vagrant sudo
printf "Enter new password for user \e[0;36m'vagrant'\e[0m\n"
sudo passwd vagrant
printf "One more time!\n"
cd ..
sudo -u vagrant -H sh -c "sudo mv newman-vm/ /home/vagrant"
sudo chown -R vagrant.vagrant /home/vagrant/newman-vm

printf "Now, logout and log back in as 'vagrant' then cd /home/vagrant/newman-vm && ./_run_me_second.sh\n"
