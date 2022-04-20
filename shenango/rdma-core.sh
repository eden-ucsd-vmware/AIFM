#!/bin/bash

set -e

rm -rf rdma-core
git submodule update --init --recursive rdma-core

pushd rdma-core
git apply ../rdma-core.patch || true

EXTRA_CMAKE_FLAGS=-DENABLE_STATIC=1 MAKEFLAGS=-j ./build.sh

popd
