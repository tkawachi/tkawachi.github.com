#!/bin/sh
set -e

echo "git@github.com:tkawachi/tkawachi.github.com.git" | bundle exec rake setup_github_pages
cd _deploy
git fetch
git reset --hard origin/master
