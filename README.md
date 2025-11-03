# studio-templates

## How to use build.sh

`VERSION=0.0.2 ./build.sh`

This should create a Build/<package-name> folders for each of the selected packages. It will set the package versions to the new one you specified, which is needed if you want to publish an update. Right now the list only contains a few selected packages, but we'll expand it as we clean up and prepare the remaining templates

## How to use publish.sh

First you have to log into npm if you didn't. We'll replace it with an auth token soon, but right now we're using username/pass credentials, so this is needed. Ask Karol or VerrDon for the credentials if you don't have them.

`npm login --registry=https://npm.highrise.game`

Then just call

`./publish.sh`

This will iterate over all the prepared packages in the Build folder and publish them one by one to the npm repository
