#!/bin/bash
# monitor-chat-list.sh - 채팅방 목록에서 미리보기 메시지 모니터링
# 채팅방 진입 없이 목록에서 마지막 메시지만 읽음
# Usage: ./monitor-chat-list.sh

# Monitored chat rooms (pattern:child:academy)
CHAT_ROOMS=(
    "연주 English:재인:영어"
    "UA MATH:재인:수학"
    "한국파워점핑:재인,여준:줄넘기"
    "잠실 에이프릴:여준:어학원"
    "구주이배:여준:바둑"
)

# State file
STATE_FILE="$HOME/.openclaw/kakaotalk-state/chat-previews.json"
mkdir -p "$(dirname "$STATE_FILE")"

echo "📱 카카오톡 채팅방 목록 모니터링"
echo "=============================================="
echo ""

# Function to get chat room list with previews
get_chat_list() {
    osascript <<'EOF'
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- Make sure main window is visible
        keystroke "w" using {command down}
        delay 0.2
        keystroke (ASCII character 27)
        delay 0.3
        
        tell window 1
            tell scroll area 1
                tell table 1
                    set rowCount to count of rows
                    set maxRows to rowCount
                    if maxRows > 100 then
                        set maxRows to 100
                    end if
                    
                    set output to ""
                    
                    repeat with i from 1 to maxRows
                        try
                            tell row i
                                tell UI element 1
                                    set staticCount to count of static texts
                                    set chatName to value of static text 1
                                    
                                    -- Get preview (second static text)
                                    set preview to ""
                                    if staticCount > 1 then
                                        set preview to value of static text 2
                                    end if
                                    
                                    -- Get unread count (third static text if exists)
                                    set unread to ""
                                    if staticCount > 2 then
                                        set unread to value of static text 3
                                    end if
                                    
                                    -- Format: name|preview|unread
                                    if length of chatName > 0 then
                                        set output to output & chatName & "|" & preview & "|" & unread & linefeed
                                    end if
                                end tell
                            end tell
                        end try
                    end repeat
                    
                    return output
                end tell
            end tell
        end tell
    end tell
end tell
EOF
}

# Get current chat list
echo "📋 채팅방 목록 읽는 중..."
chat_list=$(get_chat_list)

if [[ -z "$chat_list" ]]; then
    echo "❌ 채팅방 목록을 읽을 수 없습니다."
    exit 1
fi

# Load previous state (simple file-based approach)
prev_state_file="$HOME/.openclaw/kakaotalk-state/prev-state.txt"
mkdir -p "$(dirname "$prev_state_file")"

# Process each monitored room
total_new=0
new_messages=""

for room_info in "${CHAT_ROOMS[@]}"; do
    IFS=':' read -r pattern child academy <<< "$room_info"
    
    # Find matching chat room in list
    match=$(echo "$chat_list" | grep "$pattern" | head -1)
    
    if [[ -z "$match" ]]; then
        echo "⚠️ 채팅방 찾을 수 없음: $pattern"
        continue
    fi
    
    # Parse match: name|preview|unread
    name=$(echo "$match" | cut -d'|' -f1)
    preview=$(echo "$match" | cut -d'|' -f2)
    unread=$(echo "$match" | cut -d'|' -f3)
    
    # Check if preview changed
    prev_preview=""
    if [[ -f "$prev_state_file" ]]; then
        prev_preview=$(grep "^$name|" "$prev_state_file" 2>/dev/null | cut -d'|' -f2)
    fi
    
    if [[ "$preview" != "$prev_preview" ]] && [[ -n "$preview" ]]; then
        ((total_new++))
        new_messages+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        new_messages+="💬 $name\n"
        new_messages+="👤 자녀: $child | 학원: $academy\n"
        new_messages+="📬 미리보기: $preview\n\n"
    fi
    
    # Update state
    echo "${name}|${preview}" >> "${prev_state_file}.new"
done

# Update state file
if [[ -f "${prev_state_file}.new" ]]; then
    mv "${prev_state_file}.new" "$prev_state_file"
fi

# Output results
echo ""
if [[ $total_new -gt 0 ]]; then
    echo "🆕 새 메시지 ${total_new}개 발견!"
    echo ""
    echo -e "$new_messages"
else
    echo "✅ 새 메시지 없음"
fi

echo "=============================================="
echo "📊 모니터링 완료"