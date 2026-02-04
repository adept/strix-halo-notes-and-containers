#!/bin/bash
set -e
v=$(date +"%Y%m%d")
pkgname="dastapov/llama-swap"
podman image build -f Dockerfile.rocm-7.2 -t ${pkgname}:latest -t ${pkgname}:${v} . "$@"
