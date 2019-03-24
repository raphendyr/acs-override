#!/bin/sh

arch=$(dpkg --print-architecture)
ncpu=$(cat /proc/cpuinfo | grep -F processor | wc -l)

# Resolve source location
base=$(cd "${0%/*}" ; pwd)

# Enter kernel location
if [ "$1" -a -d "$1" ]; then
	cd "$1"
fi

echo "Working in directory: $PWD"
[ -f "Kconfig" ] || { echo "ERROR: this doesn't seem to be kernel source dir. missing Kconfig" >&2; exit 1; }

# copy patch to kernel source
for patchname in override_for_missing_acs_capabilities; do

	cp "$base/$patchname.patch" "debian/patches/$patchname"

	if ! grep -qs $patchname debian/patches/series; then
		cat >> debian/patches/series <<EOF

# Added by acs override script
$patchname
EOF
	fi

	QUILT_PC=.pc quilt push -a

	if ! grep -qs $patchname debian/changelog; then
		dch -l$(hostname) "Add $patchname.patch"
	fi
done

#nice -n2 dpkg-buildpackage -b -j3 -uc -us -tc
set -x
dpkg-buildpackage -T debian/rules.gen || true
dpkg-buildpackage -T clean && \
dpkg-buildpackage -T source && \
nice -n2 fakeroot make -j$ncpu -f debian/rules.gen binary-arch_${arch}_none && \
dpkg-buildpackage -T clean
ret=$?
set +x

(
	cd ..
	f=$(echo linux-image-*-${arch}_*_${arch}.deb)
	if [ "$f" ]; then
		for file in $f; do
			[ -e "$file" ] && echo "run: dpkg -i $PWD/$file"
		done
	fi
)

exit $ret
