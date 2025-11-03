#!/bin/bash

if [ -z "$NPM_REGISTRY" ]
then
    echo "Environment variable NPM_REGISTRY is not defined"
    exit 1;
fi

for folder in Build/*; do
    cd $folder
    npm publish --registry=$NPM_REGISTRY
    cd ../..
done
