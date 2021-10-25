#!/bin/bash

SOURCES_DIR="./Configs"
CONFIG_DIR="./private/Configurations"
if [ -d "$CONFIG_DIR" ]; then
    cp -a "$CONFIG_DIR/." $SOURCES_DIR
fi
