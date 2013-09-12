Built using the scripts as mentioned here: http://wiki.freeswitch.org/wiki/Ubuntu_Quick_Start

This is an apt repository. It can be referenced directly from github using this in your apt sources.list:

    deb https://raw.github.com/sous/freeswitch-precise/master precise main
    deb-src https://raw.github.com/sous/freeswitch-precise/master precise main

You may need to install apt-transport-https before you can reach it.

It can also be cloned locally and referred to directly:

    git clone https://github.com/sous/freeswitch-precise
    ( echo deb file://`pwd`/freeswitch-precise precise main
      echo deb-src file://`pwd`/freeswitch-precise precise main ) > /etc/apt/sources.list.d/freeswitch-precise.list

Either way, the gpg key for this repo can be imported using:

    curl https://raw.github.com/sous/freeswitch-precise/master/gnu_pub.gpg | sudo apt-key add

From this point, you can finish up the install following the Ubuntu Quick Start guide above:

    sudo apt-get -y update
    sudo apt-get -y --force-yes install freeswitch-meta-vanilla freeswitch-music freeswitch-conf-vanilla freeswitch-sysvinit freeswitch-sounds-en-us-callie
    sudo mkdir /etc/freeswitch
    sudo cp -r /usr/share/freeswitch/conf/vanilla/* /etc/freeswitch/
    sudo adduser --disabled-password  --quiet --system --home /usr/share/freeswitch --gecos "FreeSwitch Voice Platform" --ingroup daemon freeswitch
    sudo sh -c 'chown -R freeswitch:daemon /etc/freeswitch/'
    sudo sh -c 'chown -R freeswitch:daemon /usr/share/freeswitch/'
    #fix music paths
    cd /usr/share/freeswitch/sounds/music
    sudo ln -s default/8000 8000
    sudo ln -s default/16000 16000
    sudo ln -s default/32000 32000

Alternatively, this is codified in this chef cookbook: https://github.com/sous/freeswitch-cookbook

