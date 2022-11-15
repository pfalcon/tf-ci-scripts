#!/bin/bash

set -ex

docker --version

echo ""
echo "########################################################################"
echo "    Gerrit Environment"
env |grep '^GERRIT'
echo "########################################################################"

ON_EC2="0"
if [ -f /sys/hypervisor/uuid ] && grep -q ^ec2 /sys/hypervisor/uuid; then
    ON_EC2="1"
fi

if [ "${ON_EC2}" == "1" ]; then
    # On EC2 instances, stop and remove unattended-upgrades service which
    # may interfere with any apt operations below.
    sudo systemctl stop unattended-upgrades
    sudo apt-get remove -y -qq unattended-upgrades
fi

# For dpkg-architecture call below
if ! type dpkg-architecture
then
    sudo apt-get -y -qq install --no-install-recommends dpkg-dev
fi

if ! type aws
then
    sudo apt-get -y -qq update
    sudo apt-get -y -qq install --no-install-recommends unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
fi

rm -f ${WORKSPACE}/log
cd dockerfiles/

aws configure list
aws s3 cp --recursive s3://trustedfirmware-private/armclang/ .
find .

df -h

git_previous_commit=$(git rev-parse HEAD~1)
git_commit=$(git rev-parse HEAD)
files=$(git diff --name-only ${git_previous_commit} ${git_commit})
echo Changes in: ${files}
changed_dirs=$(dirname ${files}|sort -u)

update_images=""
for dir in ${changed_dirs}; do
  # Find the closest directory with build.sh.  This is, primarily,
  # to handle changes to tcwg-base/tcwg-build/tcwg-builslave/* directories.
  while [ ! -e ${dir}/build.sh -a ! -e ${dir}/.git ]; do
    dir=$(dirname ${dir})
  done
  # Add this and all dependant images in the update.
  dir_basename=$(basename ${dir})
  case "${dir_basename}" in
    "tcwg-"*)
      # ${dir} is one of generic tcwg-base/* directories.  Add dependent
      # images to the list.
      update_images="${update_images} $(dirname $(find . -path "*-${dir_basename}*/build.sh" | sed -e "s#^\./##g"))"
      ;;
    ".")
      continue
      ;;
    *)
      update_images="${update_images} $(dirname $(find ${dir} -name build.sh))"
      ;;
  esac
done
update_images="$(echo "${update_images}" | tr " " "\n" | sort -u)"

host_arch=$(dpkg-architecture -qDEB_HOST_ARCH)

for image in ${update_images}; do
  (
  cd ${image}
  image_arch=$(basename ${PWD} | cut -f2 -d '-')
  skip="skip"
  if [ -f gerrit-branches ]; then
    # Build only from branches mentioned in gerrit-branches
    if grep -q "^${GERRIT_BRANCH}\$" gerrit-branches; then
      skip="no"
    fi
  elif [ x"${GERRIT_BRANCH}" = x"master" ]; then
    # No gerrit-branch file, so build only from "master" branch.
    skip="no"
  fi
  case "${skip}:${host_arch}:${image_arch}" in
    "skip:"*)
      echo "Skipping: don't need to build ${image} on branch ${GERRIT_BRANCH}"
      ;;
    "no:amd64:amd64"|"no:amd64:i386"|"no:arm64:arm64"|"no:armhf:armhf")
      echo "=== Start build: ${image} ==="
      bash -x ./build.sh || echo "=== FAIL: ${image} ===" >> ${WORKSPACE}/log
      ;;
    *)
      echo "Skipping: can't build for ${image_arch} on ${host_arch}"
      ;;
  esac
  )||echo $image failed >> ${WORKSPACE}/log
done

