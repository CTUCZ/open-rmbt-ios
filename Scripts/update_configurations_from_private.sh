#!/bin/bash

SOURCES_DIR="./Configs"
CONFIG_DIR="./private/Configurations/Configs"
if [ -d "$CONFIG_DIR" ]; then
    cp -a "$CONFIG_DIR/." $SOURCES_DIR
fi

DESTINATION_INFO_PLIST_FILE="./Resources/RMBT-Info.plist"
INFO_PLIST_FILE="./private/Configurations/RMBT-Info.plist"
if [ -f "$INFO_PLIST_FILE" ]; then
    cp -fr $INFO_PLIST_FILE $DESTINATION_INFO_PLIST_FILE
fi

IMAGES_DIR="./private/Configurations/Images.xcassets"
DESTINATION_IMAGES_DIR="./Resources/Images.xcassets"
if [ -d "$IMAGES_DIR" ]; then
    cp -a "$IMAGES_DIR/." $DESTINATION_IMAGES_DIR
fi

exit 123
