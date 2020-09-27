#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret environment variables in Github Actions
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

image="synehan/hugo-builder"
repo="gohugoio/hugo"

build() {
  echo "Found new version, building the image ${image}:${tag}"
  docker build --no-cache --build-arg HUGO_VERSION=${tag} -t ${image}:${tag} .

  # run test
  version=$(docker run --rm ${image}:${tag} version)
  #Hugo Static Site Generator v0.70.0-7F47B99E/extended linux/amd64 BuildDate: 2020-05-06T11:26:13Z

  version=$(echo ${version}| sed -re 's|.*v([0-9]\.[0-9]{2}\.[0-9]).*|\1|')

  if [ "${version}" == "${tag}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  if [[ "${GITHUB_REF}" =~ "master" ]]; then
    if [[ ${CI} == 'true' ]]; then
      docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    fi
    docker push ${image}:${tag}
  fi
}

if [[ ${CI} == 'true' ]]; then
  tags=`curl -sL -H "Authorization: token ${GITHUB_TOKEN}"  https://api.github.com/repos/${repo}/releases |jq -r ".[].tag_name"| cut -c 2-`
else
  tags=`curl -sL https://api.github.com/repos/${repo}/releases |jq -r ".[].tag_name"| cut -c 2-`
fi

for tag in ${tags}
do
  echo $tag
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ "${status}" =~ "not found" ]]; then
    build
  fi
done

echo "Get latest version based on the latest Github release"

if [[ ${CI} == 'true' ]]; then
  latest=`curl -sL -H "Authorization: token ${GITHUB_TOKEN}"  https://api.github.com/repos/${repo}/releases/latest |jq -r ".tag_name"| cut -c 2-`
else
  latest=`curl -sL https://api.github.com/repos/${repo}/releases/latest |jq -r ".tag_name"| cut -c 2-`
fi

digest=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${latest} | jq -r ".images[].digest" )
digest_latest=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/latest | jq -r ".images[].digest" )

if [ "${digest_latest}" != "${digest}" ]; then

  echo "Update latest image to ${latest}"

  if [[ "${GITHUB_REF}" =~ "master" ]]; then
    if [[ ${CI} == 'true' ]]; then
      docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    fi
    docker pull ${image}:${latest}
    docker tag ${image}:${latest} ${image}:latest
    docker push ${image}:latest
  fi

else

  echo "Nothing to do !"

fi

