#!/usr/bin/env bash

#
# Deploy RP2040 application code
#
# @copyright 2022, Tony Smith @smittytone
# @version   1.3.0
# @license   MIT
#

# GLOBALS
timeout=30
do_build=0
do_clean=0
rpi_path="/Volumes/RPI-RP2"
uf2_path="UNDEFINED"
cmake_path="$PWD/CMakeLists.txt"

set -e

# FUNCTIONS
show_help() {
    echo -e "Usage:\n"
    echo -e "  deploy [-b][-h] /path/to/compiled/uf2/file\n"
    echo -e "Options:\n"
    echo "  -b / --build    Build the app first."
    echo "                  Default: use a pre-built version of the app"
    echo "  -c / --clean    If building the app, do a clean build."
    echo "  -h / --help     Show this help screen"
    echo
}

update_build_number() {
    build_val=$(grep 'set(BUILD_NUMBER "' ${cmake_path})
    old_num=$(echo "${build_val}" | cut -d '"' -s -f 2)
    ((new_num=old_num+1))

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sed -i "s|BUILD_NUMBER \"${old_num}\"|BUILD_NUMBER \"${new_num}\"|" "${cmake_path}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS requires slightly different syntax from Unix
        sed -i '' "s|BUILD_NUMBER \"${old_num}\"|BUILD_NUMBER \"${new_num}\"|" "${cmake_path}"
    else
        show_error "Unknown OS... build number not incremented"
    fi
}

check_for_err() {
    if [[ ${1} -ne 0 ]]; then
        exit 1
    fi
}

show_error_and_exit() {
    echo "[ERROR] $1"
}

show_error_and_exit() {
    echo "[ERROR] $1... exiting"
    exit 1
}

check_prereqs() {
    prqs=(cmake)
    for prq in "${prqs[@]}"; do
        check=$(which ${prq}) || show_error_and_exit "Required utility ${prq} not installed"
    done
}

# RUNTIME START
for arg in "$@"; do
    check_arg=${arg,,}
    if [[ "$check_arg" = "--help" || "$check_arg" = "-h" ]]; then
        show_help
        exit 0
    elif [[ "$check_arg" = "--build" || "$check_arg" = "-b" ]]; then
        do_build=1
    elif [[ "$check_arg" = "--clean" || "$check_arg" = "-c" ]]; then
        do_clean=1
    else
        uf2_path="$arg"
    fi
done

if [[ "${uf2_path}" == "UNDEFINED" ]]; then
    show_help
    exit 0
fi

# Check we have what looks like a UF2
extension="${uf2_path##*.}"
if [[ "${extension}" != "uf2" ]]; then
    show_error_and_exit "${uf2_path} does not indicate a .uf2 file"
fi

# Do we build first?
err=0
if [[ ${do_build} -eq 1 ]]; then
    # FROM 1.1.0 -- auto-update the build number
    update_build_number

    if [[ ${do_clean} -eq 1 && -d "./build" ]]; then
        rm -rf "./build"
    fi

    if [[ ! -e "./build" ]]; then
        # No build folder? Then create it
        # and configure the build
        cmake -S . -B build/ -D "CMAKE_C_COMPILER:FILEPATH=$(which arm-none-eabi-gcc)" -D CMAKE_BUILD_TYPE:STRING=Release
        check_for_err $?
    fi

    # Build the app
    cmake --build build
    check_for_err $?
fi

# Wait for the RPI_R2 mount
count=0
if [ ! -d "${rpi_path}" ]; then
    echo "Waiting for RP2040 device to mount"
    while [ ! -d "${rpi_path}" ]; do
        sleep 1
        ((count+=1))
        if [[ $count -eq $timeout ]]; then
            show_error_and_exit "RP2040 device not mounted after ${timeout}s"
        fi
    done
fi

echo "RP2040 device mounted..."

# Check for available app file
if [ ! -f "${uf2_path}" ]; then
    show_error_and_exit "Cannot find file ${uf2_path}"
fi

echo "Copying ${uf2_path} to ${rpi_path}/${uf2_path##*/}"

# Copy file
if cp -f "${uf2_path}" "${rpi_path}/${uf2_path##*/}"; then
    echo "${uf2_path##*/} copied to ${rpi_path}"
else
    show_error_and_exit " Could not copy ${uf2_path##*/} to ${rpi_path}/${uf2_path##*/}"
fi

exit 0
