#!/bin/bash

# This script toggles a virtual audio input device (a null sink)
# that can be used to route specific application audio (like Spotify)
# as a microphone input in other applications (e.g., Discord).
# It also ensures you can hear the routed Spotify audio locally.

# --- Configuration ---
# Name for the virtual null sink. This is the "virtual mic" that Discord will see.
VIRTUAL_SINK_NAME="SpotifyLoopbackSink"
# Description for the virtual null sink, as it appears in applications.
VIRTUAL_SINK_DESCRIPTION="Spotify Virtual Mic"
# Name for the loopback module that sends audio to your speakers (for local hearing).
MONITOR_LOOPBACK_MODULE_NAME="spotify-loopback-monitor-for-local-hearing-module" # Changed name for better uniqueness

# Helper Function to get default sink name
get_default_sink_name() {
    pactl info | grep "Default Sink" | awk '{print $3}'
}

# --- Function to enable the virtual microphone (null sink) and audio routing ---
enable_virtual_mic() {
    echo "Enabling Spotify audio loopback for virtual mic and local hearing..."

    # Check if the virtual sink already exists before trying to create it.
    if pactl list sinks short | grep -q "$VIRTUAL_SINK_NAME"; then
        echo "Virtual microphone '$VIRTUAL_SINK_NAME' already exists. Skipping creation."
        # If the sink exists, check if the monitor loopback is also there.
        if pactl list modules | grep -q "module-loopback" | grep -q "module_name=\"$MONITOR_LOOPBACK_MODULE_NAME\""; then
            echo "Local hearing loopback also appears to be active."
            echo "It seems the setup is already enabled. No changes made."
            return 0 # Exit successfully as it's already enabled.
        fi
    else
        # Get the current default physical sink
        DEFAULT_PHYSICAL_SINK=$(get_default_sink_name)
        if [ -z "$DEFAULT_PHYSICAL_SINK" ]; then
            echo "Error: Could not determine default physical audio sink. Exiting."
            return 1
        fi
        echo "Default physical audio sink: $DEFAULT_PHYSICAL_SINK"

        echo "Creating null sink: $VIRTUAL_SINK_NAME ('$VIRTUAL_SINK_DESCRIPTION')"
        pactl load-module module-null-sink \
            sink_name="$VIRTUAL_SINK_NAME" \
            sink_properties="device.description='$VIRTUAL_SINK_DESCRIPTION'" \
            rate=48000 channels=2
    fi

    # Give PipeWire a moment to register the new sink
    sleep 0.5

    # Get the ID of the newly created (or existing) virtual sink.
    VIRTUAL_SINK_ID=$(pactl list sinks short | grep "$VIRTUAL_SINK_NAME" | awk '{print $1}')
    if [ -z "$VIRTUAL_SINK_ID" ]; then
        echo "Error: Could not get ID for virtual sink '$VIRTUAL_SINK_NAME'. Cannot proceed."
        return 1
    fi

    # Load a loopback module to send audio from the virtual mic's monitor
    # back to your default physical sink, so you can hear the music.
    # Ensure it's not already loaded by checking its specific module_name.
    if ! pactl list modules | grep -q "module-loopback" | grep -q "module_name=\"$MONITOR_LOOPBACK_MODULE_NAME\""; then
        echo "Loading monitor loopback module for local hearing..."
        pactl load-module module-loopback \
            source="$VIRTUAL_SINK_NAME.monitor" \
            sink="$DEFAULT_PHYSICAL_SINK" \
            latency_msec=1 \
            module_name="$MONITOR_LOOPBACK_MODULE_NAME" # Use a specific module name for easy identification
    else
        echo "Monitor loopback module for local hearing already loaded."
    fi

    echo "Virtual microphone '$VIRTUAL_SINK_DESCRIPTION' created and local hearing enabled."
    echo "--- IMPORTANT MANUAL STEPS ---"
    echo "1. Start Spotify and play some music."
    echo "2. Open 'pavucontrol' (PulseAudio Volume Control)."
    echo "3. Go to the 'Playback' tab and locate Spotify."
    echo "4. Change Spotify's output to '$VIRTUAL_SINK_DESCRIPTION'."
    echo "5. In Discord (or other voice application), select '$VIRTUAL_SINK_DESCRIPTION' as your *Music Input*."
    echo "6. For your *Voice Input* in Discord, ensure your **actual microphone** is selected."
    echo "----------------------------"
}

# --- Function to disable the virtual microphone and audio routing ---
disable_virtual_mic() {
    echo "Disabling Spotify audio loopback and virtual microphone..."

    # 1. Unload all instances of the monitor loopback module (for local hearing).
    # Use 'grep -w' for whole word matching on module_name to avoid partial matches.
    MONITOR_LOOPBACK_MODULE_IDS=$(pactl list modules short | grep "$MONITOR_LOOPBACK_MODULE_NAME" | awk '{print $1}')
    if [ -n "$MONITOR_LOOPBACK_MODULE_IDS" ]; then
        for ID in $MONITOR_LOOPBACK_MODULE_IDS; do
            echo "Unloading monitor loopback module ID: $ID"
            pactl unload-module "$ID"
        done
    else
        echo "Monitor loopback module '$MONITOR_LOOPBACK_MODULE_NAME' not found or already unloaded."
    fi

    # 2. Unload the null sink module (the virtual microphone).
    # This will also remove the virtual microphone from your system.
    # Use 'grep -w' for whole word matching on sink_name.
    MODULE_ID_NULL_SINK=$(pactl list modules short | grep "module-null-sink" | grep "$VIRTUAL_SINK_NAME" | awk '{print $1}')
    if [ -n "$MODULE_ID_NULL_SINK" ]; then
        echo "Unloading null sink module ID: $MODULE_ID_NULL_SINK"
        pactl unload-module "$MODULE_ID_NULL_SINK"
        echo "Virtual microphone '$VIRTUAL_SINK_DESCRIPTION' removed."
    else
        echo "Virtual microphone '$VIRTUAL_SINK_NAME' module not found or already unloaded."
    fi

    echo "Loopback disabled. Virtual microphone removed."
    echo "--- IMPORTANT MANUAL STEP ---"
    echo "If Spotify was routed to '$VIRTUAL_SINK_DESCRIPTION', you must manually move its output back to your speakers in pavucontrol or restart Spotify."
    echo "---------------------------"
}

# --- Main toggle logic ---
# Check if the virtual sink (our virtual mic) is currently loaded.
# This is the primary indicator of whether the setup is active.
if pactl list sinks short | grep -q "$VIRTUAL_SINK_NAME"; then
    disable_virtual_mic
else
    enable_virtual_mic
fi
