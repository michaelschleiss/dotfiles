#!/usr/bin/env bash

# Get active sink name
active_sink=$(pactl get-default-sink)

# Check if the active sink has both Speaker and Headphones ports
has_speaker=$(pactl list sinks | grep -A 50 "$active_sink" | grep -F "[Out] Speaker" || true)
has_headphones=$(pactl list sinks | grep -A 50 "$active_sink" | grep -F "[Out] Headphones" || true)

if [[ -n "$has_speaker" && -n "$has_headphones" ]]; then
    # Get current active port (trimmed of leading/trailing space)
    current_port=$(pactl list sinks | grep -A 50 "$active_sink" | grep "Active Port:" | cut -d: -f2 | xargs)
    
    if [[ "$current_port" == "[Out] Headphones" ]]; then
        pactl set-sink-port "$active_sink" "[Out] Speaker"
    else
        pactl set-sink-port "$active_sink" "[Out] Headphones"
    fi
else
    # Fallback: Cycle between physically different default sinks
    sinks=($(wpctl status | grep -A 10 "Sinks:" | grep -E "[0-9]+\." | grep -oE "[0-9]+" | head -n 5))
    current=$(wpctl status | grep -A 10 "Sinks:" | grep "\*" | grep -oE "[0-9]+" | head -n 1)
    
    if [[ -z "$current" ]]; then
        wpctl set-default "${sinks[0]}"
        exit 0
    fi

    next_sink=""
    for i in "${!sinks[@]}"; do
        if [[ "${sinks[$i]}" == "$current" ]]; then
            next_index=$(( (i + 1) % ${#sinks[@]} ))
            next_sink="${sinks[$next_index]}"
            break
        fi
    done

    if [[ -n "$next_sink" ]]; then
        wpctl set-default "$next_sink"
    fi
fi
