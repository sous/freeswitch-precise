PBUILDERRC:=$(shell pwd)/.pbuilderrc

all:
	@echo "make prepare - pull down dependencies and prepare pbuilder"
	@echo "make build - build using pbuilder"
	@echo "make clean - clean things enough to push to github
	@echo "make dist-clean - clean this repo"

prepare:
	#if [ -f /var/cache/pbuilder/precise-amd64-base.tgz ]; then \
	#	sudo rm -f /var/cache/pbuilder/precise-amd64-base.tgz ;\
	#fi
	sudo apt-get update
	sudo apt-get -y install pbuilder debootstrap devscripts gdebi-core dpkg-sig
	sudo mkdir -p /var/cache/pbuilder/precise-amd64/aptcache
	sudo mkdir -p /var/cache/pbuilder/build
	sudo chmod 1777 /var/cache/pbuilder/build
	sudo mkdir -p /var/cache/archive
	sudo chown -R `whoami` /var/cache/archive/
	cp -f `pwd`/conf/pbuilderrc $(PBUILDERRC)
	perl -pi -e "s%^repodir=.\*\$$%`pwd`%" hooks.d/D01update
	echo HOOKDIR=`pwd`/hooks.d >> $(PBUILDERRC)
	#
	# If the pbuilder create errors out with this:
	#   W: Failure trying to run: chroot /var/cache/pbuilder/build/. mount -t proc proc /proc
	#
	# It's a good bet that you're running this in an lxc container. To fix this, add:
	#   lxc.aa_profile = unconfined 
	# to your container's config (then restart it) and try again
	# 
	if [ ! -f /var/cache/pbuilder/precise-amd64-base.tgz ]; then \
	  sudo pbuilder create --configfile $(PBUILDERRC) --debootstrapopts --variant=buildd ; \
	fi
	make add_dscs
	make add_repo

add_repo:
	cat apt-key.gpg | sudo apt-key add -
	if ! grep -e "^BINDMOUNTS" $(PBUILDERRC) ; then echo BINDMOUNTS=\"`pwd`\" >> $(PBUILDERRC); fi

build:
	sudo pbuilder build --configfile $(PBUILDERRC) src/freeswitch*.dsc
	make add_dscs
	make add_debs

dist-clean:
	rm -fr db/ pool/ dists/
	find . -name '*.local.upload' -exec rm -f {} \;

clean:
	rm -f .pbuilderrc

gpg:
	./generate_gpg.sh
	gpg --homedir `pwd`/gpg --armor --export > apt-key.gpg
	gpg --homedir `pwd`/gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A02CDA9F3D08B612
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv A02CDA9F3D08B612
	gpg --homedir `pwd`/gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E66C775AEBFE6C7D
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E66C775AEBFE6C7D

/usr/bin/reprepro:
	sudo apt-get -y install reprepro dpkg-sig

add_dscs: /usr/bin/reprepro gpg
	(find src -name '*.dsc' | xargs -l1 -i% reprepro -Vb . includedsc precise %) || true

add_debs: /usr/bin/reprepro gpg
	(for file in /var/cache/pbuilder/precise-amd64/result/*; do if [ -f $$file ]; then sudo mv -f $$file src ;fi ; done ) || true
	(find src -name '*.deb' | xargs -l1 -i% reprepro -Vb . includedeb precise %) || true

