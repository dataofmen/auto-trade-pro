#!/bin/bash
# kakaotalk-monitor-v2.sh - 개선된 카카오톡 채팅방 모니터링
# 검색창을 닫고 정리하는 기능 추가
# Usage: ./kakaotalk-monitor-v2.sh

# Important keywords for filtering
KEYWORDS="숙제|과제|준비물|공지|안내|필독|피드백|평가|일정|스케줄|시간|원비|납부|결제|휴원|보강|테스트|시험"
CHILD_NAMES="재인|여준|지안"

# Monitored chat rooms (name pattern:display name)
declare -a CHAT_ROOMS=("연주 English" "UA MATE" "한국파워점핑줄넘기" "잠실 에이프릴" "구주이배 잠실")

echo "📱 카카오톡 채팅방 상세 모니터링 시작..."
echo "=============================================="
echo ""

# Function to reset KakaoTalk state
reset_kakaotalk() {
    osascript <<'RESET_SCRIPT'
tell application "KakaoTalk" to activate
delay 0.3

tell application "System Events"
    tell process "KakaoTalk"
        -- Close any search popups
        repeat 2 times
            keystroke (ASCII character 27)
            delay 0.2
        end repeat
        
        -- Close any chat windows
        keystroke "w" using {command down}
        delay 0.3
        
        -- Final ESC to ensure clean state
        keystroke (ASCII character 27)
        delay 0.2
    end tell
end tell
RESET_SCRIPT
}

# Function to read messages from a chat room
read_chat_room() {
    local room_name="$1"
    
    # Reset state first
    reset_kakaotalk
    sleep 0.5
    
    osascript 2>&1 <<EOF
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- Open search with Cmd+F
        keystroke "f" using {command down}
        delay 0.8
        
        -- Clear search field and type room name
        keystroke "a" using {command down}
        delay 0.2
        keystroke "$room_name"
        delay 1.5
        
        -- Press Enter to open first matching chat
        keystroke return
        delay 2.5
        
        -- Close search popup with Escape
        repeat 2 times
            keystroke (ASCII character 27)
            delay 0.3
        end repeat
        
        -- Read messages from the chat window
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
                        if length of msgValue > 10 then
                            set end of messages to msgValue
                        end if
                    end if
                end try
            end repeat
            
            -- Get up to 3 most recent messages
            set limitedMessages to {}
            set msgCount to count of messages
            set maxMsg to 3
            if msgCount < maxMsg then
                set maxMsg to msgCount
            end if
            
            if msgCount > 0 then
                repeat with i from 1 to maxMsg
                    try
                        set end of limitedMessages to (item i of messages)
                    end try
                end repeat
                
                -- Format output
                set output to "MESSAGES: " & (count of limitedMessages) & "|SPLIT|"
                repeat with msg in limitedMessages
                    set output to output & msg & "|MSGEND|"
                end repeat
                return output
            else
                return "STATUS: NO_MESSAGES"
            end if
        end tell
    end tell
end tell
EOF
}

# Process each chat room
total_messages=0
important_found=0

for room in "${CHAT_ROOMS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💬 $room"
    echo "----------------------------------------"
    
    # Determine child and academy
    child="알수없음"
    academy="알수없음"
    case "$room" in
        *연주\ English*)
            child="재인"
            academy="영어"
            ;;
        *UA\ MATE*|*수학학원*)
            child="재인"
            academy="수학"
            ;;
        *한국파워점핑*|*줄넘기*)
            child="재인, 여준"
            academy="줄넘기"
            ;;
        *에이프릴*)
            child="여준"
            academy="어학원"
            ;;
        *구주이배*)
            child="여준"
            academy="바둑"
            ;;
    esac
    echo "👤 자녀: $child | 학원: $academy"
    echo ""
    
    # Read messages
    result=$(read_chat_room "$room")
    
    if [[ "$result" == "STATUS: NO_MESSAGES" ]]; then
        echo "📭 메시지를 찾을 수 없습니다."
        continue
    fi
    
    # Parse messages
    if [[ "$result" == MESSAGES:* ]]; then
        msg_count=$(echo "$result" | sed 's/MESSAGES: \([0-9]*\)|SPLIT|.*/\1/')
        messages=$(echo "$result" | sed 's/MESSAGES: [0-9]*|SPLIT//')
        
        echo "📬 최근 메시지 ${msg_count}개:"
        echo ""
        
        # Split messages and process each
        IFS='|MSGEND|' read -ra msg_array <<< "$messages"
        for msg in "${msg_array[@]}"; do
            [ -z "$msg" ] && continue
            ((total_messages++))
            
            # Show first 200 chars
            preview=$(echo "$msg" | head -c 200)
            [ ${#msg} -gt 200 ] && preview="${preview}..."
            echo "$preview"
            echo ""
            
            # Check for important keywords
            matched_keywords=$(echo "$msg" | grep -oE "$KEYWORDS" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//')
            matched_children=$(echo "$msg" | grep -oE "$CHILD_NAMES" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//')
            
            if [ -n "$matched_keywords" ]; then
                echo "⚠️ 중요 키워드: $matched_keywords"
                ((important_found++))
            fi
            
            if [ -n "$matched_children" ]; then
                echo "👶 언급된 자녀: $matched_children"
            fi
        done
    fi
    
    echo ""
done

# Final cleanup
reset_kakaotalk

echo "=============================================="
echo "📊 모니터링 완료"
echo "   총 메시지: $total_messages개"
echo "   중요 메시지: $important_found개"