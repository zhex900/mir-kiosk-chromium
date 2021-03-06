# Mir Kiosk Chromium 

Mir Kiosk Chromium enables to run web based kiosks on Ubuntu Core. This is forked from Gerry Boland's [mir-kiosk-chromium](https://code.launchpad.net/~gerboland/+git/chromium-snap) 

## Build

`git clone https://github.com/zhex900/mir-kiosk-chromium`

`cd mir-kiosk-chromium`

`docker run --rm -v $PWD:/project -w /project zhex900/snapcraft:core18 snapcraft`

## Install 

This is tested on Ubuntu Core 18 and 20

First install `mir-kiosk`

`sudo snap install mir-kiosk`

Install this snap package

`sudo snap install ./mir-kiosk-chromium_87.0.4280.66_amd64.snap --dangerous --devmode`

## Configuration

To customize the startup url for chromium use:

`sudo snap set mir-kiosk-chromium url="https://yoururl.com"`

Set browser refresh interval. Default is 1hr (60 mins) 

`sudo snap set mir-kiosk-chromium resettime=60`

Show nav bar

`sudo snap set mir-kiosk-chromium shownav=true`

Hide cursor (true/false)

`sudo snap set mir-kiosk-chromium hidecursor=true`

Disable kiosk mode (true/false)

`sudo snap set mir-kiosk-chromium disablekiosk=true`

## Screen orientation

`sudo vim /var/snap/mir-kiosk/current/miral-kiosk.display`. 
Append this to the end of the file.
```
  kiosk:
    cards:
    - card-id: 0
      DisplayPort-1:
        orientation: right # left or normal
```
Apply the new kiosk layout

`sudo snap set mir-kiosk display-layout=kiosk`

## Remove chrome profile lock on boot

When the kiosk is ungracefully shutdown, like lost of power. Chromium will display
a white page asking to unlock existing profile. To remove this on reboot. Existing
Chrome profile needs to be removed.

`sudo vim /etc/systemd/system/snap.mir-kiosk-chromium.mir-kiosk-chromium.service`

Add this before `ExecStart`. This will remove the profile lock when chromium crashes or ungracefully reboots.

```yaml
ExecStartPre=/usr/bin/rm -rf /root/snap/mir-kiosk-chromium/current/.config/chromium/SingletonLock
ExecStartPre=/usr/bin/rm -rf /root/snap/mir-kiosk-chromium/current/.config/chromium/SingletonCookie
ExecStartPre=/usr/bin/rm -rf /root/snap/mir-kiosk-chromium/current/.config/chromium/SingletonSocket
```

Change `Restart` to `always`. `Restart=always`

`sudo systemctl daemon-reload`

`sudo snap restart mir-kiosk-chromium`

##TODO:

1. Add travis.ci pipeline for auto build. 
1. Add screenshot capability. 

##Reference:
1. https://discourse.ubuntu.com/t/configuring-mir-kiosk-a-masterclass/8150
1. https://discourse.ubuntu.com/t/install-mir-kiosk-and-mir-kiosk-chromium-under-ubuntu-18-04-server/13108/4
