#!/usr/bin/env bash

# A simple script to help manage yum versionlock lists.
#
# versionlock.sh list-installed /tmp/basePackages
#    Write a package-per-line list of installed packages to the supplied path
#
# versionlock.sh lock-new /tmp/basePackages
#    Add a yum versionlock for any packages installed now, that aren't listed
#    in the supplied package list (generated by list-installed earlier).
#

function dumpInstalled {
	# The 'tr' fun is to get around the fact that yum list always wraps lines. This puts them back.
	yum -q list installed | tr "\n" "#" | sed -e 's/# / /g' | tr "#" "\n" | cut -d ' ' -f 1 | sort > $1
}

if [ "$1" == "list-installed" ]; then

	dumpInstalled $2

elif [ "$1" == "lock-new" ]; then

	dumpInstalled "$2-delta"

	# This may have line too long issues at some point, but doing a lock-per
	# package is not only horrendously slow, but adds a timestamp for each
	# package which makes diffs harder to understand.
	yum versionlock $(diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" $2 "$2-delta" )

fi
