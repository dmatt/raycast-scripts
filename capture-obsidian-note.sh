#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Capture Obsidian Note
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🗿
# @raycast.argument1 { "type": "text", "placeholder": "✍️🧠", "percentEncoded": true, "optional": true}

# Documentation:
# @raycast.description Takes selected text and saves it to Obsidian Vault root as .md file
# @raycast.author daniel_matteson
# @raycast.authorURL https://raycast.com/daniel_matteson

# Capture the clipboard content
TEXT=$(pbpaste)

# Get the current date and time in ISO 8601 format with timezone offset
CURRENT_DATE=$(TZ='America/Los_Angeles' date +"%Y-%m-%dT%H:%M:%S")

# Check if $1 (the first argument) is null
if [ -z "$1" ]; then
    TITLE_ENCODED=$(echo "$CURRENT_DATE" | sed 's/ /%20/g')
else
    # Replace encoded characters for '\', '/', and ':' with '%20'
    TITLE_ENCODED=$(echo "$1" | sed -e 's/%5C/%20/g' -e 's/%2F/%20/g' -e 's/%3A/%20/g')
fi

# Check if TEXT is equal to $1
TEXT_ENCODED=$(echo "$TEXT" | sed 's/ /%20/g')
TEXT_ENCODED=$(echo "$TEXT_ENCODED" | sed -e 's/\\/%20/g' -e 's/\//%20/g' -e 's/:/%20/g')
if [ "$TEXT_ENCODED" == "${TITLE_ENCODED}" ]; then
    exit 1
    echo "Error: You copied the title which overrode previous clipboard content. Try again!"
fi

# Append the special text with the current date to TEXT
TEXT="${TEXT}

#raycast-capture ${CURRENT_DATE}"

# Define the Obsidian Vault path
VAULT_PATH="/Users/danielmatteson/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain/"

# Decode the TITLE_ENCODED into a human-readable title with regular spaces
TITLE_DECODED=$(echo -e "${TITLE_ENCODED//%/\\x}")
echo "Title: ${TITLE_DECODED}"

# Save the modified TEXT to a new file in the Obsidian Vault
echo "$TEXT" > "${VAULT_PATH}${TITLE_DECODED}.md"

# Output an Obsidian URI to the new file to the Raycast script runner
echo "obsidian://open?vault=24960fd616d4507c&file=${TITLE_ENCODED}"
