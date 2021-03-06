#!/bin/bash
# Usage ./buildlocal.sh [<flavour>]

BUILDINFO="$(pwd)/buildinfo.json"
if ! [[ -r "$BUILDINFO" ]]; then echo "Cannot find $BUILDINFO file. Exiting ..."; exit 1; fi

if ! command -v jq &> /dev/null; then echo "Cannot find jq. Exiting ..."; exit 1; fi

VERSION=$(jq -r '.version' $BUILDINFO)
IMAGENAME=$(jq -r '.imagename' $BUILDINFO)
[[ $1 == "debian" ]] && FLAVOUR="debian" || FLAVOUR="alpine"

echo "Building $IMAGENAME-$VERSION (flavour: $FLAVOUR)"

# delete an existing image of the same name if it exists
# thanks to https://stackoverflow.com/questions/30543409/how-to-check-if-a-docker-image-with-a-specific-tag-exist-locally
if [[ $(docker image inspect ${IMAGENAME} 2>/dev/null) == "" ]]; then
    docker rmi -f ${IMAGENAME}:${VERSION}
fi

if [[ $FLAVOUR == "debian" ]]; then
	docker build . -t ${IMAGENAME}:${VERSION}-${FLAVOUR} -f "$(pwd)/Dockerfile.debian"
else 
	docker build . -t ${IMAGENAME}:${VERSION} -f "$(pwd)/Dockerfile"
fi
