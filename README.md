# display-input-switcher
Scripts to quickly switch between two inputs of one of your connected displays.

Using two computers on a display with a built in KVM is awesome!  
...but it quickly becomes cumbersome when you have to navigate the OSD to switch between them.  
The script, optimally bound to a hotkey, does this for you in 1 second!  

Support for **Linux** (Bash script '.sh') & **Windows** 10 (Batch script '.bat').

&nbsp;

**Contents:**
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Optimizing performance (Linux only)](#optimizing-performance)
- [Setting a hotkey](#hotkey)
- [Switching multiple monitors](#multiple-monitors)

&nbsp;

<a id="prerequisites"></a>

## 🔍 Prerequisites
Your display needs to support DDC/CI and expose the feature to select an input.  
*Most* modern monitors do this.

### Linux:  
You need to have 'ddcutil' installed. Load the kernel module with `sudo modprobe i2c-dev` or reboot your computer after installing it.  
Run `ddcutil detect` to check if your monitor is being detected.

### Windows:
You need to download [winddcutil.exe](https://github.com/scottaxcell/winddcutil/releases/tag/v2.0.0).  
It is sadly a bit more complicated to configure the script with, as it does not provide any descriptions, unlike ddcutil. I recommend using Linux instead ;)  
Open a PowerShell in the same folder and run `winddcutil.exe detect` to check if your monitor is being detected.

&nbsp;

<a id="configuration"></a>

## 📝 Configuration
[Download](https://github.com/3urobeat/display-input-switcher/releases/latest) the appropiate script for your operating system and copy it to e.g. your home directory.

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

**Tip:**  
> If you always only switch away to one input from this system, you can leave INPUT_2 empty.  
> This will skip getting the currently selected input to determine which input to switch to and directly switch to INPUT_1, saving you some time.

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

**Tip:**  
> If you always only switch away to one input from this system, you can leave INPUT_2 empty.  
> This will skip getting the currently selected input to determine which input to switch to and directly switch to INPUT_1, saving you some time.

Lastly, if you are sometimes using a third input, you can configure the script to switch to a default input instead of failing.  
Uncomment the optional setting 'DEFAULT_INPUT' and set it to one of the configured inputs.

</details>

</br>

> [!NOTE]
> If 'Input Source' 0x60 is not working for you, check out [this resource](https://github.com/rockowitz/ddcutil/wiki) for monitor/manufacturer specific information.

&nbsp;

<a id="optimizing-performance"></a>

## 🚀 Optimizing performance (Linux only)
With the current configuration ddcutil does a lot of extra checking & waiting which takes some time.  
If your monitor can handle it, you can disable these checks and in my case reduce the time to switch from 3s to just ~500ms. This drastically improves the user experience.

To disable these checks, uncomment the variable 'DDCUTIL_OPTIONS' in the script.

Should you notice failed switches, for example due to ddcutil failing to read/write, disable this option again.  
You can also attempt to diagnose issues by adding '--stats' to the 'DDCUTIL_OPTIONS' variable. This will tell ddcutil to print execution details for each request.

&nbsp;

<a id="hotkey"></a>

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
**Method 1 (PowerToys, better):**  
If you have [Microsoft PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/) installed, you can set global hotkeys just like in Linux :D  

Open the PowerToys settings and go to the Keyboard Manager menu.  
Click on "Remap a shortcut" and in the popup on "Add key remapping".  
Input your desired hotkey and select "Start App" in the "To send:" column drop down.  
Select the bat script, then save.

**Method 2 (native, worse):**  
If you don't have access to PowerToys, you can try the native approach.  
This is sadly slower, limited to <kbd>CTRL</kbd>+<kbd>ALT</kbd>+... keybinds & buggier sometimes.

Right click the script in your file explorer, and click on 'Create shortcut'.  
Right click the created shortcut, select Properties.  
Set a hotkey in the 'Shortcut key' field. You may set it to run as minimized as well.  
Save.

When pressing the hotkey, a command window should now pop up (or show up minimized) and switch your input after ~1 second.  
> When pressing the hotkey for the first time, you may see a "Run this script?" popup. Uncheck the checkbox "Always ask" and hit run.

&nbsp;

<a id="multiple-monitors"></a>

## 🖥️-🖥️ Switching multiple monitors
Switching multiple monitors at the same time is not supported by the scripts directly but we can use a little workaround.  
Make sure you have followed the 'Setting a hotkey' section above.

Duplicate the script and rename them to 'display-input-switcher-linux-display1' and 'display-input-switcher-linux-display2' for example.

### Linux:
Again, DE/WM dependent.  
Simply change the path in your hotkey configuration to run both scripts at the same time:  
`/path/to/display-input-switcher-linux-display1.sh & /path/to/display-input-switcher-linux-display2.sh`

On KDE you can click the pen symbol in the list beside the entry you have created. A popup will appear, allowing you to edit the command.  
On Hyprland, simply edit the command being executed in your config file.

### Windows:
Since Windows is a little *special*, you need a workaround for the workaround:
- Create another text file, call it 'display-input-switcher-windows.bat'. Make sure it does not end with .txt anymore.
- Right click it, Edit
- Paste (after editing '\path\to\'): `start C:\path\to\display-input-switcher-windows-display1.bat && C:\path\to\display-input-switcher-windows-display2.bat`
- Save
- Delete your old shortcut and create a new one for this file as described in the step above
