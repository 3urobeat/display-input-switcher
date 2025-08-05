# display-input-switcher
Scripts to quickly switch between two inputs of one of your connected displays.

Using two computers on one display with a built in KVM is awesome!  
...but it quickly becomes cumbersome when you have to navigate the OSD to switch between them.  
The script, optimally bound to a hotkey, does this for you in 1 second!  

Support for **Linux** (Bash script '.sh') & **Windows** 10 (Batch script '.bat').

&nbsp;

## 🔍 Prerequisites
Your display needs to support DDC/CI and expose the feature to select an input.  

### Linux:  
You need to have 'ddcutil' installed. Load the kernel module with `sudo modprobe i2c-dev` or reboot your computer after installing it.  
Run `ddcutil detect` to check if your monitor is being detected.

### Windows:
You need to download [winddcutil.exe](https://github.com/scottaxcell/winddcutil/releases/tag/v2.0.0).  
It is sadly a bit more complicated to configure the script with, as it does not provide any descriptions, unlike ddcutil. I recommend using Linux instead ;)  
Open a PowerShell in the same folder and run `winddcutil.exe detect` to check if your monitor is being detected.

&nbsp;

## 📝 Configuration
Clone the repository and copy the appropiate script to e.g. your home directory.  
On Linux you need the '...-linux.sh' bash script and on Windows the '...-windows.bat' batch script.

### Linux:
<details>
<summary>Click to unfold</summary>

Make the script executable: `chmod +x ./display-input-switcher-linux.sh`

Open the script using a text editor.  
Open a terminal and run the command `ddcutil detect`.
Look out for the display you want to switch the inputs of (the model number is listed for every entry) and take note of '/dev/i2c-MONITOR_ID'.  
Set that MONITOR_ID in the script at 'MONITOR_ID'.

In your terminal, run the command `ddcutil capabilities --bus MONITOR_ID` (replace MONITOR_ID with the value from the previous step).  
Your monitor, including all of its supported features should be printed out.

Locate a feature called 'Input Source' or 'Select Input' or something along those lines.  
Set the ID, usually 60, in the script at 'INPUT_CODE'.

Your supported inputs are listed right below. Find the two you want to switch between.  
Set both values (they are in hex) in the script at INPUT_1 & 2.  
You may set a description for both inputs to make the script's output more readable.

Lastly, if you are sometimes using a third input, you can configure the script to switch to a default input instead of failing.  
Uncomment the optional setting 'DEFAULT_INPUT' and set it to one of the configured inputs.

</details>

### Windows:
<details>
<summary>Click to unfold</summary>

Open the script using a text editor.  
Open a PowerShell in the folder where you put winddcutil.exe and run the command `.\winddcutil.exe detect`.  
One or multiple monitors should get printed out, each starting with an ID.  
> You can find out which display is the correct one by running `.\winddcutil.exe capabilities MONITOR_ID`, which will output `model(YOUR_MONITOR_MODEL_NAME)` as one of the first parameters.

In your open text editor, set the variable 'MONITOR_ID' to the ID of the monitor to switch the input of.  

The tool winddcutil does sadly not list the description of each feature code but '60' *should* be 'Input Source'.  
You should find a list of inputs of your display in the output of `.\winddcutil.exe capabilities MONITOR_ID` inside brackets after the 'Input Source' feature code. In my case it reads `60(1B 0F 11 )`.  

Which is which? Well, we again don't know. Awesome! Run `.\winddcutil.exe setvcp MONITOR_ID 0x60 0x1B` and find out. Repeat this & replace 0x1B with the other inputs (0x0F and 0x11 here) until you found your two inputs to switch between.  
Set both values (they are in hex) in the script at INPUT_1 & 2.  
You may set a description for both inputs to make the script's output more readable.

Lastly, if you are sometimes using a third input, you can configure the script to switch to a default input instead of failing.  
Uncomment the optional setting 'DEFAULT_INPUT' and set it to one of the configured inputs.

</details>

&nbsp;

## 🚀 Optimizing performance (Linux only)
With the current configuration ddcutil does a lot of extra checking & waiting which takes some time.  
If your monitor can handle it, you can disable these checks and in my case reduce the time to switch from 3s to just ~500ms.  
I can only recommend you to try it out - it drastically improved the user experience for me.

Run the command `ddcutil detect`, find your display and look out for '/dev/i2c-YOUR_ID'.  
In the script, uncomment the variable 'DDCUTIL_OPTIONS' and set YOUR_ID at '--bus YOUR_ID'.

Should you notice failed switches, for example due to ddcutil failing to read/write, disable this option again.  
You can also attempt to diagnose issues by adding '--stats' to the 'DDCUTIL_OPTIONS' variable. This will tell ddcutil to print execution details for each request.

&nbsp;

## ⌨ Setting a hotkey

### Linux:
This is obviously dependent on your Desktop Environment/Window Manager, but here are my two configs:

**KDE Plasma:**  
For KDE, open the Hotkeys menu in your system settings.  
Click + and add a script/command. Select the location of the script in the file picker that'll open up, confirm, configure a hotkey and save.  
Whenever you now hit the hotkey, KDE will launch the script in the background, which will switch your inputs around.

**Hyprland:**  
For Hyprland, open your configuration file at '~/.config/hypr/hyprland' in a text editor.  
Add a bind: In this case I chose <kbd>ALT</kbd>+<kbd>G</kbd> and the script is in my home directory:
```
bind = ALT, G, exec, ~/display-input-switcher-linux.sh
```
Upon pressing the hotkey, hyprland will launch the script in the background.

> [!NOTE]
> Be warned that this will hide any logs. Should nothing happen when pressing the hotkey, run the script manually in a terminal to verify where the issue is coming from.

### Windows:
Right click the script in your file explorer, and click on 'Create shortcut'.  
Right click the created shortcut, select Properties.  
Set a hotkey in the key combination field. You may set it to run as minimized as well.  
Save.

When pressing the hotkey, a command window should now pop up (or show up minimized) and switch your input after ~1 second.  
> When pressing the hotkey for the first time, you may see a "Run this script?" popup. Uncheck the checkbox "Always ask" and hit run.
