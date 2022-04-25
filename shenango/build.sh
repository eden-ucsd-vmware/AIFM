#!/bin/bash

#
# Build Shenango & related code
#

#defaults
NUMA_NODE=1

usage="\n
-f, --force \t\t force redo setup\n
-h, --help \t\t this usage information message\n"

# Parse command line arguments
for i in "$@"
do
case $i in
    -f|--force)
    FORCE=1
    FORCE_FLAG="--force"
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

# Ksched
cd ksched
make clean
make || { echo 'Failed to build ksched.'; exit 1; }
cd ..

# DPDK
./dpdk.sh ${FORCE_FLAG} || { echo 'Failed to build DPDK.'; exit 1; }

# RDMA
./rdma-core.sh ${FORCE_FLAG} || { echo 'Failed to build RDMA core.'; exit 1; }

# Shenango Core
make clean
make -j$(nproc) NUMA_NODE=${NUMA_NODE} || { echo 'Failed to build Shenango core.'; exit 1; }

# Bindings
cd bindings/cc
make clean
make -j$(nproc) || { echo 'Failed to build Shenango bindings.'; exit 1; }
cd ../..

# Setup
sudo ./scripts/setup_machine.sh || { echo 'Failed to setup Shenango.'; exit 1; }
