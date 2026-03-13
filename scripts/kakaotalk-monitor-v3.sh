#!/bin/bash
# kakaotalk-monitor-v3.sh - 채팅방 목록에서 직접 찾아서 메시지 읽기
# 검색(Cmd+F) 대신 채팅방 목록에서 직접 클릭 방식 사용
# Usage: ./kakaotalk-monitor-v3.sh [max_messages]
# max_messages: 채팅방당 최대 메시지 수 (기본값: 10)

MAX_MESSAGES="${1:-10}"

# Important keywords for filtering
KEYWORDS="숙제|과제|준비물|공지|안내|필독|피드백|평가|일정|스케줄|시간|원비|납부|결제|휴원|보강|테스트|시험"
CHILD_NAMES="재인|여준|지안"

# Monitored chat rooms (pattern:child:academy) - pattern must match beginning of chat room name
CHAT_ROOMS=(
    "연주 English:재인:영어"
    "UA MATH:재인:수학"
    "한국파워점핑:재인,여준:줄넘기"
    "잠실 에이프릴:여준:어학원"
    "구주이배:여준:바둑"
)

echo "📱 카카오톡 채팅방 모니터링 (목록 직접 클릭 방식)"
echo "=============================================="
echo "   채팅방당 최대 메시지: ${MAX_MESSAGES}개"
echo ""

# Function to find and click chat room in list
find_and_click_chatroom() {
    local room_pattern="$1"
    
    osascript <<EOF
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- Make sure we're in main window (close any chat windows)
        keystroke "w" using {command down}
        delay 0.3
        keystroke (ASCII character 27)
        delay 0.3
        
        -- Find chat room in list and click
        tell window 1
            tell scroll area 1
                tell table 1
                    set rowCount to count of rows
                    set maxRows to 50
                    if rowCount < maxRows then
                        set maxRows to rowCount
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
read_messages() {
    local max_msg="$1"
    
    osascript <<EOF
tell application "System Events"
    tell process "KakaoTalk"
        tell window 1
            set allElems to entire contents
            set elemCount to count of allElems
            
            -- Collect messages from text areas
            set messages to {}
            
            repeat with i from 1 to elemCount
                try
                    set elem to item i of allElems
                    set elemClass to class of elem as string
                    
                    if elemClass is "text area" then
                        set msgValue to value of elem
                        if length of msgValue > 5 then
                            set end of messages to msgValue
                        end if
                    end if
                end try
            end repeat
            
            -- Get messages (limit to max_msg)
            set msgCount to count of messages
            set limitedMessages to {}
            
            if msgCount > 0 then
                -- Determine how many messages to return
                set maxMsg to $max_msg as integer
                if msgCount < maxMsg then
                    set maxMsg to msgCount
                end if
                
                repeat with i from 1 to maxMsg
                    try
                        set end of limitedMessages to (item i of messages)
                    end try
                end repeat
            end if
            
            -- Format output
            if (count of limitedMessages) > 0 then
                set output to "COUNT:" & (count of limitedMessages) & "|SPLIT|"
                repeat with msg in limitedMessages
                    set output to output & msg & "|MSGEND|"
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
close_and_return() {
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

# Process each chat room
total_messages=0
important_found=0

for room_info in "${CHAT_ROOMS[@]}"; do
    IFS=':' read -r room_pattern child academy <<< "$room_info"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💬 $room_pattern"
    echo "----------------------------------------"
    echo "👤 자녀: $child | 학원: $academy"
    echo ""
    
    # Find and click chat room
    echo "🔍 채팅방 찾는 중..."
    find_result=$(find_and_click_chatroom "$room_pattern")
    
    if [[ "$find_result" == NOT_FOUND* ]]; then
        echo "⚠️ 채팅방을 찾을 수 없습니다: $room_pattern"
        continue
    fi
    
    # Extract actual chat room name
    actual_name=$(echo "$find_result" | sed 's/FOUND://')
    echo "✅ 채팅방 열림: $actual_name"
    sleep 1
    
    # Read messages
    echo "📜 메시지 읽는 중..."
    result=$(read_messages "$MAX_MESSAGES")
    
    if [[ "$result" == "STATUS:NO_MESSAGES" ]]; then
        echo "📭 메시지를 찾을 수 없습니다."
        close_and_return
        continue
    fi
    
    # Parse messages
    if [[ "$result" == COUNT:* ]]; then
        msg_count=$(echo "$result" | sed 's/COUNT:\([0-9]*\)|SPLIT|.*/\1/')
        messages=$(echo "$result" | sed 's/COUNT:[0-9]*|SPLIT//')
        
        echo "📬 읽은 메시지: ${msg_count}개"
        echo ""
        
        # Split messages and process each
        IFS='|MSGEND|' read -ra msg_array <<< "$messages"
        msg_idx=0
        for msg in "${msg_array[@]}"; do
            [ -z "$msg" ] && continue
            ((msg_idx++))
            ((total_messages++))
            
            echo "──────────────────────────────────────"
            echo "메시지 $msg_idx:"
            # Show full message (first 300 chars)
            preview=$(echo "$msg" | head -c 300)
            [ ${#msg} -gt 300 ] && preview="${preview}..."
            echo "$preview"
            echo ""
            
            # Check for important keywords
            matched_keywords=$(echo "$msg" | grep -oE "$KEYWORDS" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//')
            
            if [ -n "$matched_keywords" ]; then
                echo "⚠️ 중요 키워드: $matched_keywords"
                ((important_found++))
            fi
        done
    fi
    
    # Close chat and return to list
    close_and_return
    echo ""
done

echo "=============================================="
echo "📊 모니터링 완료"
echo "   총 메시지: ${total_messages}개"
echo "   중요 메시지: ${important_found}개"