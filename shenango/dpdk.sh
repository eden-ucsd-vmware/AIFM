#!/bin/bash

set -e

#
# Build DPDK
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
dpdkdir=${SCRIPT_DIR}/dpdk/
if [ -z "$(ls -A ${dpdkdir})" ] || [[ $FORCE ]]; then
    # setup
    rm -rf ${SCRIPT_DIR}/spdk
    rm -rf ${dpdkdir}

    git submodule update --init --recursive dpdk

    pushd ${dpdkdir}
    git checkout b1d36cf828771e28eb0130b59dcf606c2a0bc94d   #20.11
    patch -p 1 -d . < ../mlx5_20_11.patch
    popd 
fi

pushd $dpdkdir
meson build
ninja -C build
sudo ninja -C build install
echo "make sure pkg-config --cflags libdpdk is working at this point!"
popd

# # Previous
# Apply driver patches
# patch -p 1 -d dpdk/ < ixgbe_18_11.patch

# if lspci | grep -q 'ConnectX-[4,5]'; then
#    patch -p 1 -d dpdk/ < mlx5_18_11.patch
# elif lspci | grep -q 'ConnectX-3'; then
#     patch -p 1 -d dpdk/ < mlx4_18_11.patch
#     sed -i 's/CONFIG_RTE_LIBRTE_MLX4_PMD=n/CONFIG_RTE_LIBRTE_MLX4_PMD=y/g' dpdk/config/common_base
# fi

# Configure/compile dpdk
# make -C dpdk/ config T=x86_64-native-linuxapp-gcc
# make -C dpdk/ -j