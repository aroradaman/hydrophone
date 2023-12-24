#!/bin/bash

set -xeuo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

HYDROPHONE_ROOT=${SCRIPTDIR}/../

pushd "${HYDROPHONE_ROOT}" >/dev/null
  go mod edit -json | jq -r ".Require[] | .Path | select(contains(\"k8s.io/\"))" | xargs xargs -L1 go get -d
  go mod tidy

  K8S_VERSION=$(curl https://cdn.dl.k8s.io/release/stable.txt -s)
  sed -i "s|K8S_VERSION: .*|K8S_VERSION: $K8S_VERSION|" .github/workflows/*.yml
  sed -i "s|conformance:v(\d+\.)?(\d+\.)?(\d+)|conformance:$K8S_VERSION|" pkg/common/*.go
  sed -i "s|conformance:v(\d+\.)?(\d+\.)?(\d+)|conformance:$K8S_VERSION|" README.md

popd >/dev/null
git status