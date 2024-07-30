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

osascript -e 'display notification "Starting the Llama script..." with title "Llama Script" subtitle "🦙"'

# Capture the clipboard content
PROMPT=$(pbpaste)
osascript -e 'display notification "Clipboard content captured." with title "Llama Script" subtitle "📋"'

# Check if the clipboard content is empty
if [ -z "$PROMPT" ]; then
  osascript -e 'display notification "Clipboard is empty or pbpaste did not work correctly." with title "Llama Script" subtitle "❌ Error"'
  exit 1
fi

osascript -e 'display notification "Escaping special characters in the prompt..." with title "Llama Script" subtitle "🔍"'
# Escape special characters in the prompt
ESCAPED_PROMPT=$(echo "$PROMPT" | jq -sRr @json)

osascript -e 'display notification "Sending the prompt to the Llama 3 API..." with title "Llama Script" subtitle "📡"'

# Send the prompt to the Llama 3 API and handle the streaming response
curl -s -S --no-buffer -X POST http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d "{\"model\": \"llama3:70b-instruct-q4_0\", \"prompt\":$ESCAPED_PROMPT, \"stream\": true}" | \
while IFS= read -r line; do
  # Process each line of the response
  RESPONSE=$(echo "$line" | jq '.response' | sed 's/^"//;s/"$//')
  if [ -n "$RESPONSE" ]; then
    RESPONSE=$(echo "$RESPONSE" | sed 's/\\n/neewline/g')
    # Output the response to the user
    # Very strange way to handle newline characters, but it works (split on newlines and only hit enter for the second and subsequent lines)
    osascript <<EOF
      tell application "System Events"
          set textResponse to "$RESPONSE"
          set AppleScript's text item delimiters to "neewline"
          set textItems to text items of textResponse
          set counter to 0
          repeat with textItem in textItems
              keystroke textItem
              if counter > 0 then
                  tell application "System Events" to key code 36
              end if
              set counter to counter + 1
          end repeat
      end tell
EOF
  fi
done

osascript -e 'display notification "Done!" with title "Llama Script" subtitle "✅"'