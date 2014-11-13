#!/bin/bash

set -x
set -e

if [ ! -d .git/refs/remotes/octopress ]; then
	git remote add octopress git://github.com/imathis/octopress.git
fi
git pull octopress master     # Get the latest Octopress
bundle install                # Keep gems updated
rake update_source            # update the template's source
rake update_style             # update the template's style
git commit -a -m "Updated by octopress"
