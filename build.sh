#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REPOSITORY=tstruczynski/php
VERSIONS=( 7.0 7.1 7.2 7.3 7.4)
UPLOAD=0

declare -A VERSION_MAP
for key in "${!VERSIONS[@]}"; do VERSION_MAP[${VERSIONS[$key]}]="$key"; done  # see below

cd $SCRIPT_DIR

while getopts v:u flag
do
    case "${flag}" in
        u) UPLOAD=1;;
        v)
          if [[ ! -n "${VERSION_MAP[${OPTARG}]}" ]]; then echo "Version ${OPTARG} is unknown"; exit; fi;
          ONLY_VERSION=${OPTARG};;
    esac
done

# Exit if any of the commands fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND;' DEBUG
# echo an error message before exiting
trap 'echo -e "\n\n\"${last_command}\" command failed with exit code $?.\n\n";' EXIT

for version in "${VERSIONS[@]}"
do
  if [[ ! -z "$ONLY_VERSION" && "$version" != "$ONLY_VERSION" ]]; then
    echo "SKIPPING VERSION $version"
    continue
  fi;

  cd $version
	echo "Building version $version START"
	docker build . -t $REPOSITORY:$version
	echo "Building version $version END"
	cd ..
done

if [[ ${UPLOAD} != 1 ]]; then
  echo "Upload SKIPPED"

  exit
fi

echo "Uploading to GITHUB"

if [[ -n ${ONLY_VERSION} ]]; then
  echo "Only version ${ONLY_VERSION}"
  docker push $REPOSITORY:${ONLY_VERSION}
else
  echo "All versions"
  docker push -a $REPOSITORY
fi
