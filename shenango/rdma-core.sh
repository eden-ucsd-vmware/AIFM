#!/bin/bash

set -e

#
# Build RDMA 
#

usage="\n
-f, --force \t\t force redo setup\n
-h, --help \t\t this usage information message\n"

# Parse command line arguments
for i in "$@"
do
case $i in
    -f|--force)
    FORCE=1
    ;;

    -h | --help)
    echo -e $usage
    exit
    ;;

    *)                      # unknown option
    echo "Unkown Option: $i"
    echo -e $usage
    exit
    ;;
esac
done

SCRIPT_DIR=`dirname "$0"`
rdmadir=${SCRIPT_DIR}/rdma-core/
if ! [ -d $rdmadir ] || [[ $FORCE ]]; then
    # setup
    rm -rf ${rdmadir}
    git submodule update --init --recursive rdma-core
    pushd $rdmadir
    git apply ../rdma-core.patch || true
    popd
fi 

pushd $rdmadir
EXTRA_CMAKE_FLAGS=-DENABLE_STATIC=1 MAKEFLAGS=-j ./build.sh
popd
