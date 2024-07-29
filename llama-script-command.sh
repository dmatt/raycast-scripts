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

osascript -e 'display notification "Starting Llama script..." with title "Llama Script" subtitle "🦙"'

# Capture the clipboard content
PROMPT=$(pbpaste)
osascript -e 'display notification "Clipboard copied." with title "Llama Script" subtitle "📋"'

# Check if the clipboard content is empty
if [ -z "$PROMPT" ]; then
  osascript -e 'display notification "Clipboard is empty or pbpaste did not work correctly." with title "Llama Script" subtitle "❌ Error"'
  exit 1
fi

osascript -e 'display notification "Escaping special characters in the prompt..." with title "Llama Script" subtitle "🔍"'
# Escape special characters in the prompt
ESCAPED_PROMPT=$(echo "$PROMPT" | jq -sRr @json)

osascript -e 'display notification "Sending prompt to Llama API..." with title "Llama Script" subtitle "📡"'
# Send the prompt to the Llama 3 API and capture the output
OUTPUT=$(curl -s -S -X POST http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d "{\"model\": \"llama3:70b-instruct-q4_0\", \"prompt\":$ESCAPED_PROMPT, \"stream\": false}" | jq -r '.response')

# Check if the API response is empty
if [ -z "$OUTPUT" ]; then
  osascript -e 'display notification "Received empty response from Llama 3 API." with title "Llama Script" subtitle "❌ Error"'
  exit 1
fi

osascript -e 'display notification "Copying Llama output to clipboard..." with title "Llama Script" subtitle "📋"'
# Copy the output to the clipboard
echo "$OUTPUT" | pbcopy

osascript -e 'display notification "Pasting the output..." with title "Llama Script" subtitle "⌨️"'
# Use osascript to simulate pasting the output at the current cursor location
osascript -e 'tell application "System Events" to keystroke "v" using command down'

osascript -e 'display notification "Done!" with title "Llama Script" subtitle "✅"'
echo -e 'done'
