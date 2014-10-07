#!/bin/bash

if [ ! -d "$1" ]; then
   echo "Folder not found"
   exit 1
fi

if [ "$2" == "" ]; then
   echo "Please specify a file mask"
   exit 1
fi

if [ ! "$(id -u)" == "0" ]; then
   echo "Please run this script as root"
   exit 1
fi


# Startup
echo "Welcome to fatshuffle"
echo "Path: $1"
echo "Filemask: $2"

DEV="$(df "$1" | grep -E "^/dev" | cut -d " " -f1)"
echo "Detected device: $DEV"

# Rename
echo
echo "Rename files..."
for FILE in $1/$2; 
do

   PREFIX="$(head -c 128 /dev/urandom | sha1sum | cut -c -8)"
   DIRNAME="$(dirname "$FILE")"
   FILENAME="$(basename "$FILE" | sed 's/^fatshuffle_[a-z0-9]*_//g')"
   NEWFILENAME="fatshuffle_${PREFIX}_$FILENAME"
   mv "$FILE" "$DIRNAME/$NEWFILENAME"

done

# Unmount
echo "Trying to unmount the device..."
umount "$DEV"
if [ ! "$?" == "0" ]; then
   echo "Umount failed"
   exit 1
fi
echo "Unmount success"

# Sort
echo "Sort..."
fatsort -o d -c "$DEV"

echo "Sync..."
sync

echo "Finish"

