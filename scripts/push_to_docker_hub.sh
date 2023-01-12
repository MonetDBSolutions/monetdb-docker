#!/bin/bash

set -e

push_tag() {
    local tag="monetdb/monetdb:$1"
    echo "pushing $tag"
    docker push "$tag"
}


tag="${1?Usage: $0 TAG}"

# Recognize tags of the form Sep2022 and Sep2022-stuff
series="$(<<<"$tag" sed -n -e 's,^\([A-Z][a-z][a-z][0-9][0-9][0-9][0-9]\).*,\1,p')"

# Always push the tag itself
push_tag $tag

# If it's of the form Sep2022 or Sep2022-SP1, push 'Sep2022-latest'
if [[ -n "$series" ]]; then
    push_tag "$series-latest"
fi

# If it's of the form Sep2022, push 'latest'
if [[ -n "$series" && "$tag" = "$series" ]]; then
    push_tag "latest"
fi