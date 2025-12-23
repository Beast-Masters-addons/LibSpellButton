#!/usr/bin/env bash
curl -s https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh | bash -s -- -g classic -c -d -z
rsync -a --del .release/LibSpellButton/libs .
rm -R .release