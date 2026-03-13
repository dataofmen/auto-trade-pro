#!/bin/bash
# monitor-kakaotalk.sh - 카카오톡 선택적 모니터링
# 자녀 학원 채팅방의 새 메시지 감지
# Usage: ./monitor-kakaotalk.sh

# 모니터링 대상 채팅방 (패턴:자녀:학원)
CHAT_ROOMS=(
    "연주 English:재인:영어"
    "UA MATH:재인:수학"
    "한국파워점핑:재인,여준:줄넘기"
    "잠실 에이프릴:여준:어학원"
    "구주이배:여준:바둑"
)

# 상태 파일
STATE_DIR="$HOME/.openclaw/kakaotalk-state"
STATE_FILE="$STATE_DIR/chat-previews.txt"
mkdir -p "$STATE_DIR"

echo "📱 카카오톡 선택적 모니터링"
echo "=============================================="
echo "시작: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: 카카오톡 활성화 및 목록 로드
osascript <<'APPLESCRIPT'
tell application "KakaoTalk" to activate
delay 0.5

tell application "System Events"
    tell process "KakaoTalk"
        -- 창 닫기
        repeat 3 times
            keystroke "w" using {command down}
            delay 0.1
        end repeat
        
        -- 팝업 닫기
        repeat 3 times
            keystroke (ASCII character 27)
            delay 0.1
        end repeat
    end tell
end tell
APPLESCRIPT

# Step 2: 목록에서 채팅방 찾기
get_chat_previews() {
    osascript <<'APPLESCRIPT'
tell application "System Events"
    tell process "KakaoTalk"
        tell window 1
            tell scroll area 1
                tell table 1
                    set rowCount to count of rows
                    set maxRows to rowCount
                    if maxRows > 200 then
                        set maxRows to 200
                    end if
                    
                    set output to ""
                    
                    repeat with i from 1 to maxRows
                        try
                            tell row i
                                tell UI element 1
                                    set staticCount to count of static texts
                                    set chatName to value of static text 1
                                    
                                    set preview to ""
                                    if staticCount > 1 then
                                        set preview to value of static text 2
                                    end if
                                    
                                    if length of chatName > 0 then
                                        -- TAB을 구분자로 사용
                                        set output to output & chatName & "	" & preview & linefeed
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
APPLESCRIPT
}

echo "📋 채팅방 목록 로딩 중..."
chat_list=$(get_chat_previews)

if [[ -z "$chat_list" ]]; then
    echo "❌ 채팅방 목록을 읽을 수 없습니다."
    exit 1
fi

# Step 3: 이전 상태 로드
prev_state=""
if [[ -f "$STATE_FILE" ]]; then
    prev_state=$(cat "$STATE_FILE")
fi

# Step 4: 각 채팅방 확인
total_new=0
new_messages=""

> "${STATE_FILE}.new"

for room_info in "${CHAT_ROOMS[@]}"; do
    IFS=':' read -r pattern child academy <<< "$room_info"
    
    # 목록에서 패턴 매칭
    match=$(echo "$chat_list" | grep "$pattern" | head -1)
    
    if [[ -z "$match" ]]; then
        echo "⚠️ 채팅방 찾을 수 없음: $pattern"
        continue
    fi
    
    # 파싱 (TAB 구분자)
    name=$(echo "$match" | cut -f1)
    preview=$(echo "$match" | cut -f2)
    
    # 상태 저장
    printf "%s\t%s\n" "$name" "$preview" >> "${STATE_FILE}.new"
    
    # 이전 상태에서 찾기
    prev=$(echo "$prev_state" | grep "^${name}	" | cut -f2)
    
    # 변경 확인
    if [[ "$preview" != "$prev" ]] && [[ -n "$preview" ]]; then
        ((total_new++))
        new_messages+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        new_messages+="💬 $name\n"
        new_messages+="👤 자녀: $child | 학원: $academy\n"
        new_messages+="📬 미리보기: $preview\n\n"
    fi
done

# 상태 파일 업데이트
mv "${STATE_FILE}.new" "$STATE_FILE"

# Step 5: 결과 출력
echo ""
if [[ $total_new -gt 0 ]]; then
    echo "🆕 새 메시지 ${total_new}개 발견!"
    echo ""
    echo -e "$new_messages"
else
    echo "✅ 새 메시지 없음"
fi

echo "=============================================="
echo "완료: $(date '+%Y-%m-%d %H:%M:%S')"

exit 0