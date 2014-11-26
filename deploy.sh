#!/bin/bash

git add -A
git commit -m "Updated"
git push origin source
bundle exec rake generate deploy
