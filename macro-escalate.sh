#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Macro: Escalate
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪲

# Documentation:
# @raycast.description In a browser, run a "macro" that does shift+command+G, clicks on the element with selector "#app > div > div.flex-auto.p1.overflow-auto > div" and then clicks inside the textarea with the selector "#fldiV2uiS0g75NfzU" and then pastes what is currently into the clipboard there.
# @raycast.author daniel_matteson
# @raycast.authorURL https://raycast.com/daniel_matteson

osascript <<EOF
tell application "Arc"
    activate
    tell application "System Events"
        keystroke "g" using {shift down, command down} -- Performs shift+command+G
        delay 1 -- Adjust delay as needed to ensure the page reacts to the shortcut
        keystroke return -- Simulates pressing the Enter/Return key
        delay 1 -- Adjust delay as needed before the next action
        -- The textarea is already focused, so simulate Cmd+V to paste
        keystroke "v" using {command down}
        delay 1 -- Adjust delay as needed after pasting
        -- Hit Tab 4 times
        repeat 4 times
            keystroke tab
            delay 0.5 -- Short delay between tabs to ensure the UI can keep up
        end repeat
        -- Hit Enter
        keystroke return
        delay 1 -- Wait a short bit after hitting Return
        -- Press Esc
        keystroke escape
    end tell
end tell
EOF