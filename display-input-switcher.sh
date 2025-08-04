#!/bin/bash

# display-input-switcher by 3urobeat
# https://github.com/3urobeat/display-input-switcher-linux
# Licensed under MIT


# Run 'ddcutil capabilities' to get the values for your display

# Set the 'Input Source' Feature Code and the two inputs to switch between below.
INPUT_CODE="60"
INPUT_1="1b"            # In Hex
INPUT_1_DESC="USB-C"    # Optional: Give input a name
INPUT_2="0f"            # In Hex
INPUT_2_DESC="DP"       # Optional: Give input a name

# Optional Options for ddcutil. Enabling this option can *dramatically* speed up the script, if your monitor can handle it.
# Find your monitor's bus ID by running 'ddcutil detect'. Look out for '/dev/i2c-YOUR_ID'
#DDCUTIL_OPTIONS="--skip-ddc-checks --noverify --bus 13"    # You can show diagnostic info by adding '--stats'


# Begin
: ${DDCUTIL_OPTIONS:=""} # Set variable to nothing if disabled above

echo "Display Input Switcher v1.0"
echo "Getting current input..."

# Get current input
CURRENT=$(ddcutil getvcp $DDCUTIL_OPTIONS $INPUT_CODE) || { echo "Failed to get current input! Exiting..."; exit 1; }

# Get current input name and ID '(sl=0xINPUT_ID)' by using awk to split the string and sed to remove the trailing bracket
CURRENT_NAME=$(echo $CURRENT | awk -F ': ' '{print $2}')
CURRENT_ID=$(echo $CURRENT_NAME | awk -F 'sl=0x' '{print $2}' | sed "s/)//")

# Decide which input to switch to, convert ID for ddcutil to decimal and prepare text for log messages
if [ "$CURRENT_ID" == "$INPUT_1" ]; then
    OLD_INPUT_DESC="$INPUT_1_DESC - ID: 0x$INPUT_1"

    NEW_INPUT_DECIMAL=$(echo $((0x$INPUT_2)))
    NEW_INPUT_DESC="$INPUT_2_DESC - ID: $NEW_INPUT_DECIMAL (0x$INPUT_2)"

elif [ "$CURRENT_ID" == "$INPUT_2" ]; then
    OLD_INPUT_DESC="$INPUT_2_DESC - ID: 0x$INPUT_2"

    NEW_INPUT_DECIMAL=$(echo $((0x$INPUT_1)))
    NEW_INPUT_DESC="$INPUT_1_DESC - ID: $NEW_INPUT_DECIMAL (0x$INPUT_1)"

else
    echo "Current input '$CURRENT_NAME' ($CURRENT_ID) not recognized! Exiting..."
    exit 1
fi

echo "Current input: $OLD_INPUT_DESC"
echo "Switching to input: $NEW_INPUT_DESC"

# Run switch command
ddcutil setvcp $DDCUTIL_OPTIONS $INPUT_CODE $NEW_INPUT_DECIMAL || { echo "Failed to switch!"; exit 1; }

echo "Done!"
exit 0
