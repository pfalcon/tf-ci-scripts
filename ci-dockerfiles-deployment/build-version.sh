#!/bin/bash -e
if [ -n "${GERRIT_PATCHSET_REVISION}" ]; then
    echo "#${BUILD_NUMBER}-${GERRIT_PATCHSET_REVISION:0:8}" > ${WORKSPACE}/version.txt
else
    echo "#${BUILD_NUMBER}" > ${WORKSPACE}/version.txt
fi
