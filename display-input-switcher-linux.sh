#!/bin/bash


# display-input-switcher for Linux by 3urobeat
# https://github.com/3urobeat/display-input-switcher
# Licensed under MIT



# Run 'ddcutil detect' to find your monitor and 'ddcutil capabilities' to get the values for your display

# Set the monitor 'Model' name from 'ddcutil detect' to switch to. This attempts to automatically find MONITOR_ID
MONITOR_NAME="DELL U3223QE"
# Optional: Force set the monitor ID to switch inputs for. This overwrites anything set at MONITOR_NAME
MONITOR_ID=""
# 'Input Source' feature code in Hex
INPUT_CODE="60"
# First input to switch between, in Hex
INPUT_1="1b"
# Optional: Give input a name
INPUT_1_DESC="USB-C"
# Second input to switch between, in Hex. Leave this empty to always switch to Input 1, without checking.
INPUT_2="0f"
# Optional: Give input a name
INPUT_2_DESC="DP"

# Optional setting to switch to a default input if an unconfigured input was detected.
#DEFAULT_INPUT=$INPUT_1

# Optional parameters for ddcutil. Enabling this option can *dramatically* speed up the script, if your monitor can handle it.
#DDCUTIL_OPTIONS="--skip-ddc-checks --noverify"    # You can show diagnostic info by adding '--stats'


# -------------------------------------------------------

# Finds MONITOR_ID by model name
find_i2c_bus() {
    if [ ! "$MONITOR_ID" == "" ]; then
        echo "Monitor ID is force set to $MONITOR_ID, skipping search..."
    else
        echo "Attempting to find monitor '$MONITOR_NAME'..."

        #local src="$(ddcutil detect)"

        MONITOR_ID=$(ddcutil detect | awk -v model="$MONITOR_NAME" '
            /I2C bus:/ { bus=$NF }
            /Model:/ {
                line=$0
                sub(/^.*Model:[[:space:]]*/,"",line)
                if (line==model) {
                    if (match(bus,/i2c-([0-9]+)/,m)) print m[1]; else print bus
                    exit
                }
            }')
        echo "Found monitor ID $MONITOR_ID"
    fi
}

# Get current input
get_cur_input() {
    if [ ! "$INPUT_2" == "" ]; then
        echo "Getting current input..."
        CURRENT=$(ddcutil getvcp --bus $MONITOR_ID $DDCUTIL_OPTIONS $INPUT_CODE) || { echo "Failed to get current input! Exiting..."; exit 1; }

        # Get current input name and ID '(sl=0xINPUT_ID)' by using awk to split the string and sed to remove the trailing bracket
        CURRENT_NAME=$(echo $CURRENT | awk -F ': ' '{print $2}')
        CURRENT_ID=$(echo $CURRENT_NAME | awk -F 'sl=0x' '{print $2}' | sed "s/)//")
    else
        CURRENT_NAME="Unknown"
        CURRENT_ID="-1"
        DEFAULT_INPUT=$INPUT_1
    fi
}

# Decide which input to switch to and prepare text for log messages
get_new_input() {
    if [ "$CURRENT_ID" == "$INPUT_1" ]; then
        OLD_INPUT_DESC="$INPUT_1_DESC - ID: 0x$INPUT_1"

        NEW_INPUT=0x$INPUT_2
        NEW_INPUT_DESC="$INPUT_2_DESC - ID: $NEW_INPUT ($INPUT_2)"

    elif [ "$CURRENT_ID" == "$INPUT_2" ]; then
        OLD_INPUT_DESC="$INPUT_2_DESC - ID: $INPUT_2"

        NEW_INPUT=0x$INPUT_1
        NEW_INPUT_DESC="$INPUT_1_DESC - ID: $NEW_INPUT ($INPUT_1)"

    elif [ ! "$DEFAULT_INPUT" == "" ]; then
        OLD_INPUT_DESC="Unknown input '$CURRENT_NAME' ($CURRENT_ID)"

        NEW_INPUT=0x$DEFAULT_INPUT
        NEW_INPUT_DESC="Default - ID: $NEW_INPUT ($DEFAULT_INPUT)"

    else
        echo "Current input '$CURRENT_NAME' ($CURRENT_ID) not recognized! Exiting..."
        exit 1
    fi
}


# Begin
: ${DDCUTIL_OPTIONS:=""} # Set variable to nothing if disabled above

echo "Display Input Switcher v1.2 for Linux by 3urobeat"

find_i2c_bus
get_cur_input
get_new_input

echo "Current input: $OLD_INPUT_DESC"
echo "Switching to input: $NEW_INPUT_DESC"


# Run switch command
ddcutil setvcp --bus $MONITOR_ID $DDCUTIL_OPTIONS $INPUT_CODE $NEW_INPUT || { echo "Failed to switch!"; exit 1; }

echo "Done!"
exit 0
