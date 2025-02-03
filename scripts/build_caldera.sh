#!/bin/bash

# Recursively clone the Caldera repository if you have not done so
git clone https://github.com/mitre/caldera.git --recursive

# Build the docker image with WIN_BUILD=true to compile windows-based agents
cd caldera
docker build . --build-arg WIN_BUILD=true -t caldera:latest
