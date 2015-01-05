#!/usr/bin/env bash


apt-get -y install cmake

printf "Creating \e[0;36mMITIE\e[0m \n"

cd /srv/software 

git clone https://github.com/mitll/MITIE

cd /srv/software/MITIE

if [ -a /vagrant/artifacts/MITIE-models-v0.2.tar.bz2 ]; then
    cp /vagrant/artifacts/MITIE-models-v0.2.tar.bz2 /srv/software/MITIE/
    tar -xjf MITIE-models-v0.2.tar.bz2
else
    make MITIE-models
fi 

cd tools/ner_stream

mkdir build

cd build

cmake ..

cmake --build . --config Release

cd /srv/software/MITIE/mitielib

make