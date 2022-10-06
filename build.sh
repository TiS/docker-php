#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REPOSITORY=tstruczynski/php
VERSIONS=( 7.0 7.1 7.2 7.3 7.4 8.0 8.1)
LATEST=7.4
UPLOAD=0
last_command="";

cleanup() {
    rv=$?

    if [ "$rv" != "0" ]; then
      echo -e "\n\n\"${last_command}\" command failed with exit code $rv.\n\n";
    fi

    exit $rv
}

declare -A VERSION_MAP
for key in "${!VERSIONS[@]}"; do VERSION_MAP[${VERSIONS[$key]}]="$key"; done  # see below

cd "$SCRIPT_DIR"

while getopts v:u flag
do
    case "${flag}" in
        u) UPLOAD=1;;
        v)
          if [[ -z "${VERSION_MAP[${OPTARG}]}" ]]; then echo "Version ${OPTARG} is unknown"; exit; fi;
          ONLY_VERSION=${OPTARG};;
        *) echo -e "\n\tUnknown flag ${flag}\n"; exit 1;;
    esac
done

# Exit if any of the commands fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND;' DEBUG
# echo an error message before exiting
trap 'cleanup' EXIT

for version in "${VERSIONS[@]}"
do
  if [[ -n "$ONLY_VERSION" && "$version" != "$ONLY_VERSION" ]]; then
    echo "SKIPPING VERSION $version"
    continue
  fi;

  cd "$version"
	echo "Building version $version START"
	# shellcheck disable=SC2002
	# shellcheck disable=SC2046
	docker build . -t $REPOSITORY:"$version" $(cat .build-args | paste -s -d " " /dev/stdin)

	if [ "$version" == "$LATEST" ]; then
	  docker tag $REPOSITORY:"$version" $REPOSITORY:latest
	fi;

	echo "Building version $version END"
	cd ..
done

if [[ ${UPLOAD} != 1 ]]; then
  echo -e "\n--------------\nUpload SKIPPED\n--------------"
  exit
fi

echo "Uploading to GITHUB"

if [[ -n ${ONLY_VERSION} ]]; then
  echo "Only version ${ONLY_VERSION}"
  docker push $REPOSITORY:"${ONLY_VERSION}"

	if [ "${ONLY_VERSION}" == "$LATEST" ]; then
	  docker push $REPOSITORY:latest
	fi;
else
  echo "All versions"
  docker push -a $REPOSITORY
fi
