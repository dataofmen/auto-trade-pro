#!/bin/bash
# KakaoTalk Open Chat Room

ROOM_NAME="$1"

osascript << 'EOF'
tell application "KakaoTalk"
  activate
end tell

delay 1

tell application "System Events"
  tell process "KakaoTalk"
    -- ESC로 검색창 닫기
    keystroke (ASCII character 27)
    delay 1
  end tell
end tell
EOF

osascript << EOF
tell application "System Events"
  tell process "KakaoTalk"
    set chatRooms to rows of table 1 of scroll area 1 of window "카카오톡"
    repeat with theRow in chatRooms
      try
        set allStaticTexts to static texts of UI element 1 of theRow
        if (count of allStaticTexts) > 0 then
          set roomName to value of item 1 of allStaticTexts
          if roomName contains "$ROOM_NAME" then
            click theRow
            delay 0.5
            click theRow
            delay 2
            return "Opened: " & roomName
          end if
        end if
      end try
    end repeat
    return "Not found"
  end tell
end tell
EOF