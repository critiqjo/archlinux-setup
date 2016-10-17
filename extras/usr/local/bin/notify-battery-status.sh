#!/bin/bash

[[ "$POWER_SUPPLY_NAME" == "BAT0" ]] || exit

env > $HOME/.cache/udev-battery-env
capacity=$POWER_SUPPLY_CAPACITY
energy_now=$POWER_SUPPLY_ENERGY_NOW
energy_full=$POWER_SUPPLY_ENERGY_FULL
urgency="normal"

[[ "$POWER_SUPPLY_STATUS" == "Discharging" && "$capacity" -le 20 ]] && urgency="critical"

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
notify-send --urgency=$urgency "Battery: ${capacity}% ( $((energy_now / 1000)) / $((energy_full / 1000)) )"
