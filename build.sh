#!/usr/bin/env bash
set -euo pipefail

main() {
  cd "$(dirname "$0")/../.."
  source ./ci/lib.sh

  docker build -t "phisanti/vscode-notebook-$ARCH:$VERSION" -f ./Dockerfile .
}

main "$@"
