#!/bin/bash

SOURCES_DIR="./Configs"
CONFIG_DIR="./private/Configuration"
if [ -d "$CONFIG_DIR" ]; then
    cp -a "$CONFIG_DIR/." $SOURCES_DIR
fi

exit 123
