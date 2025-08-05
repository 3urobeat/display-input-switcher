@ECHO OFF
SETLOCAL enabledelayedexpansion
SET PARENT=%~dp0


:: display-input-switcher for Windows by 3urobeat
:: https://github.com/3urobeat/display-input-switcher
:: Licensed under MIT


:: Run 'winddcutil.exe detect' to find your monitor and 'winddcutil.exe capabilities MONITOR_ID' to get the values for your display

:: Set the monitor ID to switch inputs for
SET MONITOR_ID=3
:: 'Input Source' feature code in Hex
SET INPUT_CODE=60
:: First input to switch between, in Hex
SET INPUT_1=1b
:: Optional: Give input a name
SET INPUT_1_DESC=USB-C
:: Second input to switch between, in Hex
SET INPUT_2=0f
:: Optional: Give input a name
SET INPUT_2_DESC=DP

:: Optional setting to switch to a default input if an unconfigured input was detected.
::SET DEFAULT_INPUT=%INPUT_1%


:: Begin
echo Display Input Switcher v1.1 for Windows by 3urobeat
echo Getting current input...

:: Get current input
FOR /F "tokens=3" %%g IN ('%parent%\winddcutil.exe getvcp %MONITOR_ID:"=% 0x%INPUT_CODE:"=%') do (SET CURRENT=%%g)

IF %errorlevel% NEQ 0 (echo Failed to get current input! Exiting... && exit 1)
IF "%CURRENT%" == "" (echo Failed to get current input! Exiting... && exit 1)

set /A INPUT_1_DECIMAL=0xF%INPUT_1%
set /A INPUT_2_DECIMAL=0xF%INPUT_2%

:: Decide which input to switch to and prepare text for log messages
IF "%CURRENT%" == "%INPUT_1_DECIMAL%" (
    SET OLD_INPUT_DESC=%INPUT_1_DESC% - ID: %INPUT_1%

    SET NEW_INPUT=0x%INPUT_2%
    SET NEW_INPUT_DESC=%INPUT_2_DESC% - ID: !NEW_INPUT!
) ELSE IF "%CURRENT%" == "%INPUT_2_DECIMAL%" (
    SET OLD_INPUT_DESC=%INPUT_2_DESC% - ID: %INPUT_2%

    SET NEW_INPUT=0x%INPUT_1%
    SET NEW_INPUT_DESC=%INPUT_1_DESC% - ID: !NEW_INPUT!

) ELSE IF NOT "%DEFAULT_INPUT%" == "" (
    SET OLD_INPUT_DESC=Unknown input '%CURRENT%'

    SET NEW_INPUT=0x%DEFAULT_INPUT%
    SET NEW_INPUT_DESC=Default - ID: !NEW_INPUT!

) ELSE (
    echo Current input '%CURRENT%' not recognized! Exiting...
    exit 1
)

echo Current input: %OLD_INPUT_DESC%
echo Switching to input: %NEW_INPUT_DESC%

:: Run switch command
%parent%winddcutil.exe setvcp %MONITOR_ID:"=% 0x%INPUT_CODE:"=% %NEW_INPUT:"=% || (echo Failed to switch! && exit 1)

echo Done!
