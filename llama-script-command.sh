#!/bin/bash

# Raycast Script Command
#
# Takes input from the clipboard, and sends it as a prompt to Llama 3 via Ollama REST API, and
# outputs the result back to where your cursor was before you stared the script.
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Llama
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🦙
# @raycast.packageName Raycast Scripts

# Capture the clipboard content
PROMPT=$(pbpaste)

# Check if the clipboard content is empty
if [ -z "$PROMPT" ]; then
  echo "Error: Clipboard is empty or pbpaste did not work correctly."
  exit 1
fi

# Escape special characters in the prompt
ESCAPED_PROMPT=$(echo "$PROMPT" | jq -sRr @json)

# Send the prompt to the Llama 3 API and capture the output
OUTPUT=$(curl -s -S -X POST http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d "{\"model\": \"llama3:70b-instruct-q4_0\", \"prompt\":$ESCAPED_PROMPT, \"stream\": false}" | jq -r '.response')

# Check if the API response is empty
if [ -z "$OUTPUT" ]; then
  echo "Error: Received empty response from Llama 3 API."
  exit 1
fi

# Copy the output to the clipboard
echo "$OUTPUT" | pbcopy

# Use osascript to simulate pasting the output at the current cursor location
osascript -e 'tell application "System Events" to keystroke "v" using command down'