#!/bin/bash
pushd ~/vault/
git pull && git add -A && git commit -m 'update' && git push
popd
