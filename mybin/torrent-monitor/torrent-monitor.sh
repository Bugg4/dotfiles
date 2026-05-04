#!/bin/bash

# Created: by opencode
# Features:
# - Queries LimeTorrents (works without FlareSolverr)
# - Tracks previously seen torrents using title+size
# - Sends ntfy.sh notification for new results
# - State stored in ~/.torrent-monitor-state
# To run hourly via cron:
# crontab -e
# Add this line:
# 0 * * * * /tmp/test/torrent-monitor.sh

JACKETT_URL="http://127.0.0.1:9117"
API_KEY="kbjpghhdyy7jbankd57vji2mudqz9rvx"
INDEXER="limetorrents"
SEARCH_TERM="masterchef italia TheBlackKing"
NTFY_TOPIC="masterchef_hdjwohxo2bfi9anebxokqn3919ujx"
STATE_FILE=".torrent-monitor-state"

QUERY_URL="${JACKETT_URL}/api/v2.0/indexers/${INDEXER}/results/torznab/api?apikey=${API_KEY}&t=search&q=$(echo "$SEARCH_TERM" | sed 's/ /+/g')"

response=$(curl -s "$QUERY_URL")

if [ $? -ne 0 ] || [ -z "$response" ]; then
	echo "Error: Failed to fetch results from Jackett"
	exit 1
fi

items=$(echo "$response" | tr '\n' ' ' | grep -oP '<item>.*?</item>')

if [ -z "$items" ]; then
	echo "No results found for: $SEARCH_TERM"
	exit 0
fi

current_keys=""
while IFS= read -r item; do
	title=$(echo "$item" | grep -oP '<title>[^<]+</title>' | sed 's/<title>//g;s/<\/title>//g' | head -1)
	size=$(echo "$item" | grep -oP '<size>[^<]+</size>' | sed 's/<size>//g;s/<\/size>//g' | head -1)
	if [ -n "$title" ] && [ -n "$size" ]; then
		key="${title}|${size}"
		current_keys="${current_keys}${key}"$'\n'
	fi
done <<<"$items"

current_keys=$(echo "$current_keys" | sort)

if [ -f "$STATE_FILE" ]; then
	previous_keys=$(cat "$STATE_FILE")
else
	previous_keys=""
fi

new_count=0
new_results=""

while IFS= read -r item; do
	title=$(echo "$item" | grep -oP '<title>[^<]+</title>' | sed 's/<title>//g;s/<\/title>//g' | head -1)
	size=$(echo "$item" | grep -oP '<size>[^<]+</size>' | sed 's/<size>//g;s/<\/size>//g' | head -1)
	seeds=$(echo "$item" | grep -oP 'name="seeders" value="[^"]+' | grep -oP 'value="[^"]+' | sed 's/value="//g' | head -1)

	key="${title}|${size}"

	if ! echo "$previous_keys" | grep -Fxq "$key"; then
		if [ -n "$title" ]; then
			((new_count++))
			size_gb=$(echo "scale=2; $size / 1073741824" | bc 2>/dev/null || echo "")
			new_results="${new_results}${title}"
			if [ -n "$size_gb" ]; then
				new_results="${new_results} (${size_gb}GB)"
			fi
			new_results="${new_results} - Seeds: ${seeds:-0}"
			new_results="${new_results}"$'\n'
		fi
	fi
done <<<"$items"

if [ "$new_count" -gt 0 ]; then
	message="Found $new_count new torrent(s) for \"${SEARCH_TERM}\":"$'\n\n'"${new_results}"

	curl -s -H "X-Title: New Torrents Found" \
		-H "X-Priority: 3" \
		-d "$message" \
		"https://ntfy.sh/${NTFY_TOPIC}"

	echo "Notification sent: $new_count new torrent(s) found"
fi

echo "$current_keys" >"$STATE_FILE"

echo "Check complete. Found $new_count new torrent(s)."
