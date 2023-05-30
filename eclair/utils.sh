#!/usr/bin/env python3
#
# Copyright (c) 2022-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Common utility functions for Bugseng ECLAIR tool.

# Directory where this script resides (assuming it was sourced).
export _ECLAIR_UTILS_DIR="$(cd "$(dirname "$BASH_SOURCE")" ; echo "${PWD}")"

# Absolute path of the ECLAIR bin directory.
ECLAIR_BIN_DIR="/opt/bugseng/eclair/bin"

# Directory where to put all ECLAIR output and temporary files.
ECLAIR_OUTPUT_DIR="${WORKSPACE}/ECLAIR/out"

# ECLAIR binary data directory and workspace.
export ECLAIR_DATA_DIR="${ECLAIR_OUTPUT_DIR}/.data"

PROJECT_ECD="${ECLAIR_OUTPUT_DIR}/PROJECT.ecd"


eclair_prepare() {
    mkdir -p "${ECLAIR_DATA_DIR}"
}

eclair_analyze() {
    (
        # Run a build in the ECLAIR environment.
        "${ECLAIR_BIN_DIR}/eclair_env"                   \
            "-eval_file='${ECLAIR_CONFIG_DIR}/MISRA_C_2012_selection.ecl'" \
            -- "$@"
    )
}

eclair_make_ecd() {
    # Create the project database.
    find "${ECLAIR_DATA_DIR}" -maxdepth 1 -name "FRAME.*.ecb" \
        | sort | xargs cat \
        | "${ECLAIR_BIN_DIR}/eclair_report" \
            "-create_db='${PROJECT_ECD}'" \
            -load=/dev/stdin
}

eclair_make_report_self_contained() {
    dir=$1
    mkdir -p $dir/lib

    cp -r /opt/bugseng/eclair-3.12.0/lib/html $dir/lib

    ${_ECLAIR_UTILS_DIR}/relativize_urls.py $dir
}

eclair_make_reports() {
    ${ECLAIR_BIN_DIR}/eclair_report -db=${PROJECT_ECD} \
        -summary_txt=${ECLAIR_OUTPUT_DIR}/../summary_txt \
        -full_txt=${ECLAIR_OUTPUT_DIR}/../full_txt \
        -reports1_html=strictness,${ECLAIR_OUTPUT_DIR}/../full_html/by_strictness/@TAG@.html \
        -full_html=${ECLAIR_OUTPUT_DIR}/../full_html \
        -full_xml=${ECLAIR_OUTPUT_DIR}/../full_xml

    # summary_txt contains just a single report file not present in full_txt, move it there and be done with it.
    mv ${ECLAIR_OUTPUT_DIR}/../summary_txt/by_service.txt ${ECLAIR_OUTPUT_DIR}/../full_txt/
    rm -rf ${ECLAIR_OUTPUT_DIR}/../summary_txt

    eclair_make_report_self_contained ${ECLAIR_OUTPUT_DIR}/../full_html
}
