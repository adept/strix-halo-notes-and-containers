#!/bin/bash

podman run -it --rm -p 8080:8080 \
 --name llama-swap \
 --device /dev/kfd --device /dev/dri \
 --group-add keep-groups \
 -v ~/models:/models \
 -v ~/models/llama-swap:/config \
 dastapov/llama-swap:latest -config /config/config.yaml -watch-config
