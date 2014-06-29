#!/bin/bash
#title          :music_library_mp3fier.sh
#description    :Copies a folder of music while converting FLAC's to 320 kbps MP3's. Preserves filenames, tags, directory hierarchy, and cover art. Source MP3's are simply copied. Conversion happens in parallel (one file per core).
#author         :Ingvaras Merkys (crunch)
#date           :2014-06-29
#version        :1
#usage          :./music_library_mp3fier.sh ./source/ ./destination\ folder
#notes          :Requirements: avconv, libmp3lame, parallel. Supported formats: flac, mp3, png, jpg.
#bash_version   :4.3.11(1)-release
#============================================================================

function convert_to_mp3() {
    INPUT="$1"
    SOURCE="$2"
    TARGET="$3"
    OUTPUT=${INPUT/$SOURCE/$TARGET}
    OUTPUT=${OUTPUT/.flac/.mp3}
    avconv -i "$INPUT" -c libmp3lame -vn -b 320k "$OUTPUT"
}
export -f convert_to_mp3

SCRIPT_DIR=$(pwd)

# Get absoulute source
cd "$1"
SOURCE=$(pwd)

# Go back, create TARGET, and get its absolute
cd "$SCRIPT_DIR"
mkdir -p "$2"
cd "$2"
TARGET=$(pwd)/${SOURCE##*/}
mkdir -p "$TARGET"

# Copy directory structure
cd "$SOURCE"
find . -type d -exec mkdir -p "$TARGET"/{} \;

# Run the conversion
find "$SOURCE" -type f | grep --ignore-case ".*\.flac$" | parallel -j+0 convert_to_mp3 {} "\"$SOURCE\"" "\"$TARGET\""

# Copy artwork and mp3s
OIFS="$IFS"
IFS=$'\n'
for file in $(find "$SOURCE" -type f | grep --ignore-case ".*\.jpg$\|.*\.jpeg$\|.*\.png$\|.*\.mp3$")
do
    OUTPUT=${file/$SOURCE/$TARGET}
    cp "$file" "$OUTPUT"
done
IFS="$OIFS"
