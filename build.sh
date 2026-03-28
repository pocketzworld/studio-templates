#!/bin/bash

set -e

echo "Wiping the build folder"
rm -rf Build
mkdir Build

if [ -z "$VERSION" ]; then
    echo "Environment variable VERSION is not defined"
    exit;
fi

templates=""

for template in *_Template; do
    if [ ! -e "$template/package.json" ]; then
        continue
    fi

    package=`cat $template/package.json | jq .name | xargs echo`

    index=`cat Metadata/metadata.json | jq "(.templates + .internalTemplates) | map(.packageName) | index(\"$package\")"`

    if [ "null" != "$index" ]
    then
        templates="$templates $template"
    fi
done

for template in $templates; do
    name=`cat $template/package.json | jq .displayName | xargs echo`
    package=`cat $template/package.json | jq .name | xargs echo`

    echo "Preparing $package"

    mkdir Build/$package
    mkdir Build/$package/ProjectSettings

    cp -R $template/Assets Build/$package/Assets
    cp -R $template/Library~ Build/$package/Library
    cp $template/ProjectSettings/EditorBuildSettings.asset Build/$package/ProjectSettings/EditorBuildSettings.asset
    if [ -e $template/ProjectSettings/WorldSettings.asset ]; then
        cp $template/ProjectSettings/WorldSettings.asset Build/$package/ProjectSettings/WorldSettings.asset
    fi
    echo "{\"name\":\"$name\",\"id\":\"$package\"}" > Build/$package/ProjectSettings/TemplateInfo.json

    if [ -e "$template/.extra-build-files" ]; then
        for subpath in `cat $template/.extra-build-files | xargs echo`; do
            cp $template/$subpath Build/$package/$subpath
        done
    fi

    sed "s/PACKAGE_VERSION/$VERSION/" $template/package.json > Build/$package/package.json
done

package=`cat Metadata/package.json | jq .name | xargs echo`

echo "Preparing $package"
cp -R Metadata Build/$package

sed "s/PACKAGE_VERSION/$VERSION/" Metadata/package.json > Build/$package/package.json
