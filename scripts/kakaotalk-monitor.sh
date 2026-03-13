#!/bin/zsh
# KakaoTalk Chat Room Monitor
# Monitors unread message counts for children's chat rooms

CHATROOMS=(
  "연주 English tr."
  "UA MATE 수학학원"
  "잠실 에이프릴어학원"
  "구주이배 잠실본원 2관"
  "한국파워점핑줄넘기"
)

CHILD_MAP=(
  "연주 English tr.:재인"
  "UA MATE 수학학원:재인"
  "잠실 에이프릴어학원:여준"
  "구주이배 잠실본원 2관:여준"
  "한국파워점핑줄넘기:재인,여준"
)

STATE_FILE="$HOME/.openclaw/workspace-developer/data/kakaotalk-state.json"
LOG_FILE="$HOME/.openclaw/workspace-developer/logs/kakaotalk-monitor.log"

# Ensure directories exist
mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get unread count for a chat room using AppleScript
get_unread_count() {
  local room_name="$1"
  
  osascript << EOF 2>/dev/null
tell application "KakaoTalk"
  activate
end tell

delay 1

tell application "System Events"
  tell process "KakaoTalk"
    set chatRooms to rows of table 1 of scroll area 1 of window "카카오톡"
    repeat with theRow in chatRooms
      try
        set allStaticTexts to static texts of UI element 1 of theRow
        if (count of allStaticTexts) >= 1 then
          set roomName to value of item 1 of allStaticTexts
          if roomName contains "$room_name" then
            set textCount to count of allStaticTexts
            if textCount >= 3 then
              set unreadText to value of item textCount of allStaticTexts
              return unreadText as string
            end if
            return "0"
          end if
        end if
      end try
    end repeat
    return "NOT_FOUND"
  end tell
end tell
EOF
}

# Main monitoring function
monitor() {
  log "Starting KakaoTalk monitoring..."
  
  # Load previous state
  typeset -A previous_counts
  if [[ -f "$STATE_FILE" ]]; then
    while IFS=':' read -r room count; do
      previous_counts["$room"]="$count"
    done < "$STATE_FILE"
  fi
  
  # Current state
  typeset -A current_counts
  local alerts=()
  
  for room in "${CHATROOMS[@]}"; do
    local count=$(get_unread_count "$room")
    current_counts["$room"]="$count"
    log "Room: $room, Unread: $count"
    
    # Check for new messages
    local prev="${previous_counts[$room]:-0}"
    if [[ "$count" != "NOT_FOUND" && "$count" != "$prev" ]]; then
      local diff=$((count - prev))
      if [[ $diff -gt 0 ]]; then
        alerts+=("📱 $room: ${diff}개 새 메시지 (총 $count)")
      fi
    fi
  done
  
  # Save current state
  > "$STATE_FILE"
  for room in "${CHATROOMS[@]}"; do
    echo "$room:${current_counts[$room]}" >> "$STATE_FILE"
  done
  
  # Output alerts
  if [[ ${#alerts[@]} -gt 0 ]]; then
    echo "=== NEW MESSAGES DETECTED ==="
    for alert in "${alerts[@]}"; do
      echo "$alert"
    done
    echo "============================="
  else
    echo "No new messages in monitored chat rooms."
  fi
}

# Run monitoring
monitor