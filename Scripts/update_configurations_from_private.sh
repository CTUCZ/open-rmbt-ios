#!/bin/bash

SOURCES_DIR="./Configs"
CONFIG_DIR="./private/Configurations/Configs"
if [ -d "$CONFIG_DIR" ]; then
    cp -a "$CONFIG_DIR/." $SOURCES_DIR
else
    CONFIG_DIR="./public/Configurations/Configs"
    cp -a "$CONFIG_DIR/." $SOURCES_DIR
fi

DESTINATION_INFO_PLIST_FILE="./Resources/RMBT-Info.plist"
INFO_PLIST_FILE="./private/Configurations/RMBT-Info.plist"
if [ -f "$INFO_PLIST_FILE" ]; then
    cp -fr $INFO_PLIST_FILE $DESTINATION_INFO_PLIST_FILE
else
    INFO_PLIST_FILE="./public/Configurations/RMBT-Info.plist"
    cp -fr $INFO_PLIST_FILE $DESTINATION_INFO_PLIST_FILE
fi

DESTINATION_IMAGES_DIR="./Resources/Images.xcassets"
IMAGES_DIR="./private/Configurations/Images.xcassets"
if [ -d "$IMAGES_DIR" ]; then
    cp -a "$IMAGES_DIR/." $DESTINATION_IMAGES_DIR
else
    IMAGES_DIR="./public/Configurations/Images.xcassets"
    cp -a "$IMAGES_DIR/." $DESTINATION_IMAGES_DIR
fi
