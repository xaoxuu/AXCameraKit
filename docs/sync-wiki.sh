#!/usr/bin/env bash
#
# This script can be used to sync the wiki submodule
# in case you're using github internal wiki option
#

git pull origin master
cd docs/wiki
git pull origin master
cd ../..
git commit -a -m "updated docs/wiki"
git push origin master
