---
layout: post
date: 2017-10-18
title: Unlocking an Android Smartphone with a Known Pattern Lock via ADB
categories: mobile security
tags:
  - android
  - pattern-lock
---

Recently my [Nexus 4](https://en.wikipedia.org/wiki/Nexus_4) touchscreen stopped
working.

I wasn't worried at all because I set up an automatic backup schedule with
[Titanium Backup](https://play.google.com/store/apps/details?id=com.keramidas.TitaniumBackup&hl=it)
that runs every night and uploads backup data to Google Drive. So everything
under control right? Not so fast.

I was able to restore everything on a spare Nexus 4 (that a friend lent me)
except of my
[bank's app](https://play.google.com/store/apps/details?id=com.unicredit&hl=it).
More precisely: I was able to restore the app and related data but it was not
enough because this app also checks if the Android ID is what it's expecting.
Being the two IDs different (I did not restore the Android ID with Titanium
Backup), the app (correctly) asked me to authenticate the new device. The only
problem is that for such authentication I needed a
[One Time Password (OTP)](https://en.wikipedia.org/wiki/One-time_password)
generated via the app itself. I was locked out because I could not generate new
codes with the app on my old Nexus 4 (touchscreen not working) and the geniuses
that designed the bank's authentication system did not think about backup codes.

So what to do? What are the alternatives?

- (Solution for a normal person) buy a 2$ USB OTG cable and connect a USB mouse
to the phone
- (Solution for an Engineer) simulate touch input via
[Android Debug Bridge](https://developer.android.com/studio/command-line/adb.html)

Guess which path I chose...

## Goal

The goal of this exercise is to **unlock an Android system protected with a known
pattern lock by simulating the touch input via ADB**.

Note that the approach described below is applicable not only to
"pattern-locked" phones, but to all the cases when you cannot use the
touchscreen.

## Prerequisites

1. An Android smartphone or tablet with either **USB Debugging mode enabled
and an authorized ADB host to connect via ADB** or **unlocked bootloader and
custom recovery (I tested the procedure with [TWRP](https://twrp.me/))**
1. An ADB host (I used a Linux box)

## Connect Target Android Device via ADB

1. Reboot your device in *recovery mode*
1. Start ADB on the host machine

    ```shell
    ferrarim@nuc-ferrarim:~$ adb devices
    * daemon not running. starting it now on port 5037 *
    * daemon started successfully *
    ```

1. Connect the target phone via USB
1. Confirm that ADB correctly recognized the phone:

    ```shell
    ferrarim@nuc-ferrarim:~$ adb devices
    List of devices attached
    0123456789abcdef    device
    ```

## Enable USB Debugging

You can skip this step if you already have USB Debugging enabled on the target
device. Remember that your phone must have a custom recovery installed (like
TWRP that defaults to *root* access when connecting via ADB).

1. Enable USB debugging via a root `adb shell`:

    ```shell
    ferrarim@nuc-ferrarim:~$ adb shell
    mako:/ $ echo "persist.service.adb.enable=1" >>/system/build.prop
    mako:/ $ echo "persist.service.debuggable=1" >>/system/build.prop
    mako:/ $ echo "persist.sys.usb.config=mass_storage,adb" >>/system/build.prop
    mako:/ $ exit
    ```

## Authorize the ADB Host

If your ADB host is already authorized (i. e. you are able to connect via ADB
when the target device is not running in recovery), you can skip this step.

Let's copy your ADB public key to the target device (this will overwrite the
all the keys you have authorized in the past, so you may want to backup your `/data/misc/adb/adb_keys`
file before manipulating it):

```shell
ferrarim@nuc-ferrarim:~$ adb push ~/.android/adbkey.pub /data/misc/adb/adb_keys
```

## Reboot the Target Device in Normal Mode

If the target device is in recovery mode, let's reboot it

```shell
ferrarim@nuc-ferrarim:~$ adb reboot
```

## Fix the "no permission" Error when Connecting via ADB

If you are not able to connect to the target device when it's in normal mode and
you see the following output when running `adb devices`:

```shell
ferrarim@nuc-ferrarim:~$ adb devices
List of devices attached
????????????   no permissions
```

You can try a couple of tricks:

- Reboot the ADB server:

  ```shell
  ferrarim@nuc-ferrarim:~$ adb kill-server
  ferrarim@nuc-ferrarim:~$ adb start-server
  ```

- If the above does not solve the issue, try setting the following `udev` rules in
`/etc/udev/rules.d/XX-android.rules` where *XX* is a your desired prefix to set
the order in which this rule file should be parsed considering other rule files.
If you don't need to enforce a particular order, just choose a prefix such as
this rule file will end up at the end of the list of rule files
(i. e. `zz99-android.rules`):

  ```shell
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0e79", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0502", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="413c", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="091e", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="12d1", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="24e3", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="2116", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0482", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="17ef", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="1004", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="22b8", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0409", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="2080", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="2257", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="10a9", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="1d4d", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0471", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="04da", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="1f53", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="04dd", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0fce", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0930", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="19d2", MODE="0666"
  SUBSYSTEM=="usb", ATTRS{idVendor}=="1bbb", MODE="0666"
  ```

  Then setup file permissions, restart `udev` and ADB server:

  ```shell
  ferrarim@nuc-ferrarim:~$ chmod 644   /etc/udev/rules.d/zz99-android.rules
  ferrarim@nuc-ferrarim:~$ chown root. /etc/udev/rules.d/zz99-android.rules
  ferrarim@nuc-ferrarim:~$ service udev restart
  ferrarim@nuc-ferrarim:~$ killall adb
  ferrarim@nuc-ferrarim:~$ adb start-server
  ```

  You should now have a fully working ADB environment connected to the target
  device (in normal mode).

## Simulating Touch Input via ADB

We can simulate a user touching the screen and pressing buttons via ADB, but we
first have to know the coordinates of the points to touch. After that you need
to unlock the device, swipe up to reach the pattern lockscreen and then swipe
the pattern.

### Get the Coordinates of the Pattern Lock Points

To get the X and Y coordinates of the points to touch you should:

1. Run an instance of the Android emulator and set it to the same resolution as
the target device or run a physical device that, again, has the same resolution
as the target device
1. Connect to such device via ADB
1. Listen for touch events:

    ```shell
    ferrarim@nuc-ferrarim:~$ adb shell getevent -l
    ```

1. Touch each point of the pattern screen and write down its coordinates. Here
is the output of a touch event that you are listening for. `ABS_MT_POSITION_X`
and `ABS_MT_POSITION_Y` are the X and Y coordinates expressed in [Hexadecimal
numeral system](https://en.wikipedia.org/wiki/Hexadecimal)

    ```shell
    /dev/input/event3: EV_KEY       BTN_TOUCH            DOWN
    /dev/input/event3: EV_ABS       ABS_MT_POSITION_X    000002f5
    /dev/input/event3: EV_ABS       ABS_MT_POSITION_Y    0000069e
    ```

1. Convert the nine (X,Y) tuples from Hexadecimal to Decimal

Now you have the X and Y for each one of the nine points of the pattern lock.

### Run the Pattern Script

Before developing my own script I found an existing implementation on GitHub.
[I forked that project](https://github.com/ferrarimarco/android-pattern-unlock)
and adapted it to my own needs (I set the (X,Y) coordinates of each point of the
pattern lock and the pattern lock itself).

The script does the following:

1. Turn the screen on by simulating a power button press:

    ```shell
    adb shell input keyevent 26
    ```

1. Swipe up to reach the pattern lock screen:

    ```shell
    adb shell input swipe ${SWIPE_UP_X} ${SWIPE_UP_Y_FROM} ${SWIPE_UP_X} ${SWIPE_UP_Y_TO}
    ```

1. Simulate the unlock pattern:

    ```shell
    # Start touch event
    adb shell sendevent /dev/input/event2 3 57 14

    # Simulate input. $PATTERN is the unlock pattern of the target device
    for NUM in $PATTERN; do
        echo "Sending $NUM: ${X[$NUM]}, ${Y[$NUM]}"
        adb shell sendevent /dev/input/event2 3 53 ${X[$NUM]}
        adb shell sendevent /dev/input/event2 3 54 ${Y[$NUM]}
        adb shell sendevent /dev/input/event2 3 58 57
        adb shell sendevent /dev/input/event2 0 0 0
    done

    # End touch event
    adb shell sendevent /dev/input/event2 3 57 4294967295
    adb shell sendevent /dev/input/event2 0 0 0
    ```

## Conclusions

With the right tools it was possible to do the following with the target device,
with all the security patches applied and the latest version of Android (
LineageOS, 7.1.2):

- Gain root access
- Forcibly enable the USB Debug mode
- Authorize an ADB host to connect to the device
- Simulate touch input

All of this was possible for one single reason: **I unlocked the bootloader of
my Android smartphone and installed a custom recovery that granted me (or anyone
with physical access to the device) ROOT privileges.**

I would avoid doing it on devices that you intend to use to store sensitive
data. On such devices you should also enable full-disk encryption!
