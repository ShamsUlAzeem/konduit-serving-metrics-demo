#!/usr/bin/env bash

echo "Building Docker image."
docker build -t local/konduit-demo:v1 .

echo "Finished build."
echo
echo "Start demo by running: docker-copose up"
