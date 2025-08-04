# display-input-switcher-linux
Script written in Bash to quickly switch between two inputs of one of your connected displays.

Using two computers on one display with a built in KVM is awesome!  
...but it quickly becomes cumbersome when you have to navigate the OSD to switch between them.  
This script, optimally bound to a hotkey, does this for you in 1 second!  

&nbsp;

## Prerequisites
Your display needs to support DDC/CI and expose the feature to select an input.  
You need to have 'ddcutil' installed. You may have to reboot your computer after installing it.

Run `ddcutil detect` to check if your monitor is being detected.

&nbsp;

## Configuration
Clone the repository and copy the script to e.g. your home directory.  
Make the script executable: `chmod +x ./display-input-switcher.sh`

Open the script using a text editor.  
In your terminal, run the command `ddcutil capabilities`.  
Your monitor, including all of its supported features should be printed out.

Locate a feature called 'Input Source' or 'Select Input' or something along those lines.  
Set the ID, for me 60, in the script at 'INPUT_CODE'.

Your supported inputs are listed right below. Find the two you want to switch between.  
Set both values (they are in hex) in the script at INPUT_1 & 2.  
You may set a description for both inputs to make the script's output more readable.

Lastly, if you are sometimes using a third input, you can configure the script to switch to a default input instead of failing instead.  
Uncomment the optional setting 'DEFAULT_INPUT' and set it to one of the configured inputs.

&nbsp;

## Optimizing performance
With the current configuration ddcutil does a lot of extra checking & waiting which takes some time.  
If your monitor can handle it, you can disable these checks and in my case reduce the time to switch from 3s to just ~500ms.  
I can only recommend you to try it out - it drastically improved the user experience for me.

Run the command `ddcutil detect`, find your display and look out for '/dev/i2c-YOUR_ID'.  
In the script, uncomment the variable 'DDCUTIL_OPTIONS' and set YOUR_ID at '--bus YOUR_ID'.

Should you notice failed switches, for example due to ddcutil failing to read/write, disable this option again.  
You can also attempt to diagnose issues by adding '--stats' to the 'DDCUTIL_OPTIONS' variable. This will tell ddcutil to print execution details for each request.

&nbsp;

## Setting a hotkey
This is obviously dependent on your Desktop Environment/Window Manager, but here are my two configs:

**KDE Plasma**  
For KDE, open the Hotkeys menu in your system settings.  
Click + and add a script/command. Select the location of the script in the file picker that'll open up, confirm, configure a hotkey and save.  
Whenever you now hit the hotkey, KDE will launch the script in the background, which will switch your inputs around.

**Hyprland**  
For Hyprland, open your configuration file at '~/.config/hypr/hyprland' in a text editor.  
Add a bind: In this case I chose <kbd>ALT</kbd>+<kbd>G</kbd> and the script is in my home directory:
```
bind = ALT, G, exec, ~/display-input-switcher.sh
```
Upon pressing the hotkey, hyprland will launch the script in the background.

&nbsp;

Be warned that this will hide any logs. Should nothing happen when pressing the hotkey, run the script manually in a terminal to verify where the issue is coming from.
