ACS Overrride patch for debian
==============================

Here is ACS Override patch updated to different debian kernel packages.
In addition, there is script that will apply patch, update changelog and build debian package.

Check version history for patches for different kernel releases.

**WARNING**: Using this patch is not recommended. Use it only if you know what you are doing and you really really need to.

Original patch: https://lkml.org/lkml/2013/5/30/513

Background: http://vfio.blogspot.fi/2014/08/iommu-groups-inside-and-out.html

Script usage
------------

Get linux source:

```sh
sudo -i

cd /usr/src/

apt-get source linux-image-4.11.0-1-amd64  # change this
```

Apply patch, build package and install it:

```sh
path/to/acs_override/apply-patch.sh linux-4.11.6/

dpkg -i linux-image-4.11.0-1-amd64_4.11.6-1`hostname`1_amd64.deb
```

How to update patch
-------------------

```sh
export QUILT_PC=.pc

dquilt new override_for_missing_acs_capabilities
dquilt add drivers/pci/quirks.c 
dquilt add Documentation/kernel-parameters.txt 
dquilt add Documentation/admin-guide/kernel-parameters.tx
patch -p1 < path/to/override.patch 
nano drivers/pci/quirks.c # make fixes
dquilt refresh # update patch file
dquilt header -e # set comment
cp debian/patches/override_for_missing_acs_capabilities path/to/override.patch
```
