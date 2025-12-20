#!/bin/bash
# Automatically clean cache if disk usage >= 99%

# === SETTINGS ===
THRESHOLD=99
DISK="/"  # the partition to monitor (root)

# === GET CURRENT USAGE ===
USAGE=$(df -h "$DISK" | awk 'NR==2 { print $5}')

# === CHECK USAGE ===
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "⚠️  Disk usage is at ${USAGE}%. Starting cleanup..."

    # Cleanup commands
    rm -rf /var/cache/apt/archives/*
    rm -rf /var/cache/fwupd/*
    rm -rf /var/cache/fwupdmgr/*
    rm -rf /var/cache/man/*
    rm -f  /var/cache/motd-news
    rm -rf /var/cache/snapd/*

    echo "✅ Cache cleaned. Rechecking disk space..."
    df -h "$DISK"
else
    echo "✅ Disk usage is ${USAGE}%, below threshold (${THRESHOLD}%). No cleanup needed."
fi
