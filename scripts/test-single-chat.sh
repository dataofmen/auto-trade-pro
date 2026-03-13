#!/bin/bash
# test-single-chat.sh - 단일 채팅방 테스트
# Usage: ./test-single-chat.sh "채팅방이름"

CHAT_ROOM_NAME="${1:-강철병원}"

echo "📱 단일 채팅방 테스트: $CHAT_ROOM_NAME"
echo "=============================================="

# Function to find and click chat room in list (NO SEARCH)
find_and_click_chatroom() {
    local room_pattern="$1"
    
    osascript <<EOF
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- Close any chat windows first, return to main list
        keystroke "w" using {command down}
        delay 0.3
        keystroke (ASCII character 27)
        delay 0.3
        
        -- Find chat room in list and click
        tell window 1
            tell scroll area 1
                tell table 1
                    set rowCount to count of rows
                    set maxRows to rowCount
                    if maxRows > 100 then
                        set maxRows to 100
                    end if
                    
                    repeat with i from 1 to maxRows
                        try
                            tell row i
                                tell UI element 1
                                    set chatName to value of static text 1
                                    if chatName contains "$room_pattern" then
                                        -- Found! Click to open
                                        click
                                        return "FOUND:" & chatName
                                    end if
                                end tell
                            end tell
                        end try
                    end repeat
                end tell
            end tell
        end tell
        
        return "NOT_FOUND"
    end tell
end tell
EOF
}

# Function to read messages from current chat window
read_messages_from_chat() {
    local max_msg="$1"
    
    osascript <<EOF
tell application "System Events"
    tell process "KakaoTalk"
        -- Wait for messages to load
        delay 2.0
        
        tell window 1
            -- Get all elements and find text areas
            set allElems to entire contents
            set elemCount to count of allElems
            
            set messages to {}
            
            repeat with i from 1 to elemCount
                try
                    set elem to item i of allElems
                    set elemClass to class of elem as string
                    
                    if elemClass is "text area" then
                        set msgValue to value of elem
                        if length of msgValue > 10 then
                            set end of messages to msgValue
                        end if
                    end if
                end try
            end repeat
            
            -- Limit messages
            set msgCount to count of messages
            set maxMsg to $max_msg as integer
            if msgCount < maxMsg then
                set maxMsg to msgCount
            end if
            
            if msgCount > 0 then
                set output to "MESSAGES:" & maxMsg & "|SPLIT|"
                repeat with i from 1 to maxMsg
                    try
                        set output to output & (item i of messages) & "|MSGEND|"
                    end try
                end repeat
                return output
            else
                return "STATUS:NO_MESSAGES"
            end if
        end tell
    end tell
end tell
EOF
}

# Function to close chat and return to list
close_chat() {
    osascript <<'EOF'
tell application "System Events"
    tell process "KakaoTalk"
        -- Close chat window
        keystroke "w" using {command down}
        delay 0.3
        -- ESC to ensure clean state
        keystroke (ASCII character 27)
        delay 0.3
    end tell
end tell
EOF
}

echo "🔍 채팅방 목록에서 찾는 중..."
find_result=$(find_and_click_chatroom "$CHAT_ROOM_NAME")

if [[ "$find_result" == NOT_FOUND* ]]; then
    echo "⚠️ 채팅방을 찾을 수 없습니다: $CHAT_ROOM_NAME"
    exit 1
fi

# Extract actual chat room name
actual_name=$(echo "$find_result" | sed 's/FOUND://')
echo "✅ 채팅방 열림: $actual_name"

# Read messages
echo "📜 메시지 읽는 중..."
result=$(read_messages_from_chat "5")

# Close chat window
close_chat

if [[ "$result" == "STATUS:NO_MESSAGES" ]]; then
    echo "📭 메시지를 찾을 수 없습니다."
    exit 0
fi

# Parse messages
if [[ "$result" == MESSAGES:* ]]; then
    msg_count=$(echo "$result" | sed 's/MESSAGES:\([0-9]*\)|SPLIT|.*/\1/')
    messages=$(echo "$result" | sed 's/MESSAGES:[0-9]*|SPLIT//')
    
    echo "📬 읽은 메시지: ${msg_count}개"
    echo ""
    
    # Split messages and process each
    IFS='|MSGEND|' read -ra msg_array <<< "$messages"
    msg_idx=0
    for msg in "${msg_array[@]}"; do
        [ -z "$msg" ] && continue
        ((msg_idx++))
        
        echo "──────────────────────────────────────"
        echo "메시지 $msg_idx:"
        # Show full message (first 500 chars)
        preview=$(echo "$msg" | head -c 500)
        [ ${#msg} -gt 500 ] && preview="${preview}..."
        echo "$preview"
        echo ""
    done
fi

echo "=============================================="
echo "✅ 완료"