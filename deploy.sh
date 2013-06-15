#!/bin/bash

set -e

git add .
git commit -m "Updated"
git push origin source
bundle exec rake generate deploy
