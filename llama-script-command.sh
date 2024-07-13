#!/bin/bash

# Raycast Script Command
#
# This script takes input from the clipboard, invokes a Python script to process it using LLaMa,
# and outputs the result directly in the Raycast interface.
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title LLaMa
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🦙
# @raycast.packageName Raycast Scripts

# Capture the clipboard content
PROMPT=$(pbpaste)

OUTPUT=$(curl -s -S -X POST http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d "{\"model\": \"llama3:70b-instruct-q4_0\", \"prompt\":\"$PROMPT\", \"stream\": false}" | jq -r '.response')

echo "$OUTPUT"

# Copy the output to the clipboard
echo "$OUTPUT" | pbcopy

# Escape double quotes and backslashes in $OUTPUT
ESCAPED_OUTPUT=$(echo "$OUTPUT" | sed 's/\\/\\\\/g' | sed 's/\"/\\\"/g')

# Use osascript to simulate typing the output at the current cursor location
osascript -e "tell application \"System Events\" to keystroke \"$ESCAPED_OUTPUT\""