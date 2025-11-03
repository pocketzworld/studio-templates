#!/bin/bash

set -e

if [ -z "$SOURCE_NPM_REGISTRY" ]
then
    >&2 echo "Environment variable SOURCE_NPM_REGISTRY is not defined"
    exit 1;
fi

if [ -z "$NPM_REGISTRY" ]
then
    >&2 echo "Environment variable NPM_REGISTRY is not defined"
    exit 1;
fi

if [ -z "$VERSION" ]
then
    >&2 echo "Environment variable VERSION is not defined"
    exit 1;
fi

BUILD_DIR=./Build

fetch_package() {
    package_name=$1

    echo "Fetching $package_name metadata"
    package_metadata=`curl $SOURCE_NPM_REGISTRY/$package_name`
    tarball_url=`echo $package_metadata | jq ".versions[\"$VERSION\"].dist.tarball" | xargs echo`

    if [ "null" = "$tarball_url" ]
    then
        echo "Couldn't locate $package_name package version $VERSION in the source registry $SOURCE_NPM_REGISTRY"
        exit 1;
    fi

    mkdir -p $BUILD_DIR/$package_name

    echo "Fetching $package_name archive"
    curl $tarball_url > $BUILD_DIR/$package_name/package.tgz

    echo "Unpacking $package_name"
    cd $BUILD_DIR/$package_name
    tar --strip-components=1 -zxf package.tgz
    rm package.tgz
    cd -

    echo "Package $package_name copied successfully"
    echo
}

echo "Cleaning the build directory"
rm -rf $BUILD_DIR

metadata_package=`cat Metadata/package.json | jq .name | xargs echo`

fetch_package $metadata_package

other_packages=`cat $BUILD_DIR/$metadata_package/metadata.json | jq '.templates[].packageName' | tr '"' ' ' | xargs echo`

for pkg in $other_packages
do
    echo $pkg
    fetch_package $pkg
done
