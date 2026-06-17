#!/bin/bash

# scraper.sh: Scrapes media at yande.re,konachan.com,danbooru.donmai.us

# read -p "Enter the tag: " TAG
# read -p "Enter the booru: " BOORU
# read -p "Enter the limit (optional): " LIMIT

HARDCODED_EXCLUDED_TAG=+-transparent_png
YANDERE_URL="https://yande.re"
KONACHAN_URL="https://konachan.com"
DANBOORU_API="https://danbooru.donmai.us/posts.json?tags="
API_QUERY="/post.json?tags="

if [ -z "$1" ] || [ -z "$2" ]; then
 # No tag and booru specified.
  echo "Usage: `basename $0` tag booru"
  echo "Booru options: yandere, konachan, danbooru"
  exit 1
fi

TAG=$1
BOORU=$2
LIMIT=$3

TAGS=$(echo "$TAG" | tr '+' '_')

# if [ -z "$TAG" ] || [ -z "$BOORU" ]; then
#  No tag and booru specified.
#   echo "A tag is required."
#   echo "A booru is required."
#   exit 1
# fi

case "$BOORU" in
  yandere)
    URL="${YANDERE_URL}${API_QUERY}${TAG}${HARDCODED_EXCLUDED_TAG}"
    DIR="yandere_$TAGS"
    JQ_FILTER='.[].jpeg_url'
    ;;
  konachan)
    URL="${KONACHAN_URL}${API_QUERY}${TAG}"
    DIR="konachan_$TAGS"
    JQ_FILTER='.[].jpeg_url'
    ;;
  danbooru)
    URL="${DANBOORU_API}${TAG}"
    DIR="danbooru_$TAGS"
    JQ_FILTER='.[].file_url'
    ;;
  *)
    echo "Invalid booru."
    echo "Valid options: yandere, konachan, danbooru"
    exit 1
    ;;
esac

# Pass limit parameter if provided
if [ -n "$LIMIT" ]; then
  URL="${URL}&limit=${LIMIT}"
fi

mkdir -p "$DIR"

# Download medias
curl -s "$URL" | jq -r "$JQ_FILTER" | aria2c -c -i- -d "$DIR"
