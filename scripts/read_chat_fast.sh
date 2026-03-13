#!/bin/bash
# read_chat_fast.sh - 빠른 채팅방 메시지 읽기
# 검색 방식 사용, entire contents 순회 최소화
# Usage: ./read_chat_fast.sh "채팅방이름" [최대메시지수]

CHAT_ROOM_NAME="$1"
MAX_MESSAGES="${2:-5}"

if [ -z "$CHAT_ROOM_NAME" ]; then
    echo "사용법: $0 \"채팅방이름\" [최대메시지수]"
    exit 1
fi

echo "📱 $CHAT_ROOM_NAME 채팅방 메시지 읽기"
echo "=============================================="

# Step 1: Open chat room via search
osascript <<EOF
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- Open search
        keystroke "f" using {command down}
        delay 0.8
        
        -- Clear and type
        keystroke "a" using {command down}
        delay 0.2
        keystroke "$CHAT_ROOM_NAME"
        delay 1.5
        
        -- Open first result
        keystroke return
        delay 2.0
        
        -- Close search
        repeat 2 times
            keystroke (ASCII character 27)
            delay 0.3
        end repeat
    end tell
end tell
EOF

echo "✅ 채팅방 열림"
echo "📜 메시지 읽는 중..."

# Step 2: Read messages (with AppleScript timeout)
result=$(osascript <<EOF
with timeout of 30 seconds
    tell application "System Events"
        tell process "KakaoTalk"
            tell window 1
                try
                    set allElems to entire contents
                    set elemCount to count of allElems
                    
                    set messages to {}
                    set maxToCheck to 100
                    if elemCount < maxToCheck then
                        set maxToCheck to elemCount
                    end if
                    
                    repeat with i from 1 to maxToCheck
                        try
                            set elem to item i of allElems
                            set elemClass to class of elem as string
                            
                            if elemClass is "text area" then
                                set msgValue to value of elem
                                if length of msgValue > 10 then
                                    set end of messages to msgValue
                                    if (count of messages) >= $MAX_MESSAGES then
                                        exit repeat
                                    end if
                                end if
                            end if
                        end try
                    end repeat
                    
                    if (count of messages) > 0 then
                        set output to ""
                        repeat with msg in messages
                            set output to output & msg & "|MSGEND|"
                        end repeat
                        return output
                    else
                        return "NO_MESSAGES"
                    end if
                on error errMsg
                    return "ERROR:" & errMsg
                end try
            end tell
        end tell
    end tell
end timeout
EOF
)

# Step 3: Close chat
osascript <<'EOF'
tell application "System Events"
    tell process "KakaoTalk"
        keystroke "w" using {command down}
        delay 0.3
        keystroke (ASCII character 27)
    end tell
end tell
EOF

# Parse results
if [[ "$result" == "NO_MESSAGES" ]]; then
    echo "📭 메시지를 찾을 수 없습니다."
elif [[ "$result" == ERROR:* ]]; then
    echo "❌ 오류: ${result#ERROR:}"
else
    echo "📬 읽은 메시지:"
    echo ""
    IFS='|MSGEND|' read -ra msg_array <<< "$result"
    msg_idx=0
    for msg in "${msg_array[@]}"; do
        [ -z "$msg" ] && continue
        ((msg_idx++))
        echo "[$msg_idx]"
        echo "$msg" | head -c 300
        echo ""
        echo "---"
    done
    echo ""
    echo "총 ${msg_idx}개 메시지"
fi