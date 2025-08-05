#!/bin/bash


# display-input-switcher for Linux by 3urobeat
# https://github.com/3urobeat/display-input-switcher
# Licensed under MIT



# Run 'ddcutil detect' to find your monitor and 'ddcutil capabilities' to get the values for your display

# Set the monitor ID to switch inputs for
MONITOR_ID="13"
# 'Input Source' feature code in Hex
INPUT_CODE="60"
# First input to switch between, in Hex
INPUT_1="1b"
# Optional: Give input a name
INPUT_1_DESC="USB-C"
# Second input to switch between, in Hex
INPUT_2="0f"
# Optional: Give input a name
INPUT_2_DESC="DP"

# Optional setting to switch to a default input if an unconfigured input was detected.
#DEFAULT_INPUT=$INPUT_1

# Optional parameters for ddcutil. Enabling this option can *dramatically* speed up the script, if your monitor can handle it.
#DDCUTIL_OPTIONS="--skip-ddc-checks --noverify"    # You can show diagnostic info by adding '--stats'


# Begin
: ${DDCUTIL_OPTIONS:=""} # Set variable to nothing if disabled above

echo "Display Input Switcher v1.1 for Linux by 3urobeat"
echo "Getting current input..."

# Get current input
CURRENT=$(ddcutil getvcp --bus $MONITOR_ID $DDCUTIL_OPTIONS $INPUT_CODE) || { echo "Failed to get current input! Exiting..."; exit 1; }

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

elif [ ! "$DEFAULT_INPUT" == "" ]; then
    OLD_INPUT_DESC="Unknown input '$CURRENT_NAME' ($CURRENT_ID)"

    NEW_INPUT_DECIMAL=$(echo $((0x$DEFAULT_INPUT)))
    NEW_INPUT_DESC="Default - ID: $NEW_INPUT_DECIMAL (0x$DEFAULT_INPUT)"

else
    echo "Current input '$CURRENT_NAME' ($CURRENT_ID) not recognized! Exiting..."
    exit 1
fi

echo "Current input: $OLD_INPUT_DESC"
echo "Switching to input: $NEW_INPUT_DESC"

# Run switch command
ddcutil setvcp --bus $MONITOR_ID $DDCUTIL_OPTIONS $INPUT_CODE $NEW_INPUT_DECIMAL || { echo "Failed to switch!"; exit 1; }

echo "Done!"
exit 0
