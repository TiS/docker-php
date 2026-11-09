#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REPOSITORIES=(tstruczynski/php ghcr.io/tis/docker-php)
VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4 8.5)
LATEST=8.3
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

  echo "Building version $version START"
	docker build \
	  -f "docker/Dockerfile.${version}" \
	  -t "${REPOSITORIES[0]}":"$version" \
	  --label "org.opencontainers.image.source=https://github.com/TiS/docker-php" \
	  --label "org.opencontainers.image.description=Docker PHP image with additional services and extensions." \
	  --label "org.opencontainers.image.licenses=MIT" \
	  docker

	for repository in "${REPOSITORIES[@]}"
	do
	  docker tag "${REPOSITORIES[0]}":"$version" "$repository":"$version"

    if [ "$version" == "$LATEST" ]; then
      docker tag "${REPOSITORIES[0]}":"$version" "$repository":latest
    fi;
	done

	echo "Building version $version END"
done

if [[ ${UPLOAD} != 1 ]]; then
  echo -e "\n--------------\nUpload SKIPPED\n--------------"
  exit
fi

echo "Uploading to repositories"

if [[ -n ${ONLY_VERSION} ]]; then
  echo "Only version ${ONLY_VERSION}"
  for repository in "${REPOSITORIES[@]}"; do
    docker push "$repository":"${ONLY_VERSION}";

    if [ "${ONLY_VERSION}" == "$LATEST" ]; then
      docker push "$repository":latest
    fi;
  done
else
  echo "All versions"
  for repository in "${REPOSITORIES[@]}"; do docker push -a "$repository"; done
fi
