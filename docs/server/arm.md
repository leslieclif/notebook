- [Amlogic S905W Installation](https://forum.armbian.com/topic/17106-installation-instructions-for-tv-boxes-with-amlogic-cpus/)
- [Download Ubuntu ARM 64 Bit OS](https://users.armbian.com/balbes150/arm-64/)
check for focal current image.xz package
- On Windows use Etcher to update the image after extraction into SD Card.
- On Linux, go to `/boot/dtb/meson-gxl-s905w-p281.dtb` and copy the file name.
- Use the above file name and update file `/boot/extlinux/extlinux.conf` as per instruction Amlogic S905W Installation.
- Copy uboot file at root named `u-boot-s905x-s912` as `u-boot.ext`
- [Configure wireless network details](https://raspberrypi.stackexchange.com/questions/10251/prepare-sd-card-for-wifi-on-headless-pi)
```BASH
# Use su to edit the below files.
/etc/network/interfaces
# Add or uncomment the lines
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    post-up ifdown eth0
iface default inet dhcp

/etc/wpa_supplicant/wpa_supplicant.conf
# Add below contents and update Wifi details
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YOUR_SSID_HERE"
    psk="YOUR_SECRET_PASSPHRASE_HERE"
    id_str="SOME_DESCRIPTIVE_NAME"
}
```
- Extract SD Card and insert inside Tx device to boot from new SD Card.

- After boot, check the IP address assigned in Router DHCP Client list
- SSH into Tx device IP as `ssh root@IP`, default passw0rd is 1234.
- Create new Sudo user and reset passwd.

- Update OS, type `armbian-config` in the terminal to configure the device.
- System --> Firmware --> Update System and then reboot
- `sudo apt-update` if that fails for libc-bin package, force pin the version and install it.
```BASH
sudo apt install libc6=2.31-0ubuntu9.2 libc-bin=2.31-0ubuntu9.2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y && sudo apt-get clean -y
```
- Update NAND frequency in case EEMC (internal 2GB RAM and 8GB ROM) is not detected.
Use this [guide](https://forum.armbian.com/topic/15665-new-x96mini-hardware-upgraded-but-no-emmc-found/).
```BASH
# You need to unpack your dtb file into dts via device-tree-compile tool. 
sudo apt-get install device-tree-compiler
# decompile the dtb file
dtc -I dtb -O dts -o meson-gxl-s905w-p281.dts meson-gxl-s905w-p281.dtb
# Edit using sudo in BOOT/dtb/amlogic searching for "mmc@74000" block
max-frequency = <0x5f5e100>;
5f5e100 in hex = 100000000 in dec
edit it to 0x2faf080, 50000000 in dec 
# compile with 
dtc -I dts -O dtb -o meson-gxl-s905w-p281.dtb meson-gxl-s905w-p281.dts
# Delete the dts file
# Remove SD card and inside into Tx device
```
- Get system diagonastics `armbianmonitor -u`, which is stored in html.
- Copy Boot directory to internal EEMC chip using `./install-aml.sh` present in the root home directory. Remove the SD card and use the Tx device henceforth.
- After reboot usig EEMC, `armbian-config` -- System and 3rd Party Software, Install Full Firmware Packages.
- Use armbian-config to set static IP to Tx device
```BASH
nmcli con show
sudo nmtui      # Use UI to update IP
```
# Product Specs of Amlogic S905W Android TV Box
Model NO. 	    M18
CPU 	        Amlogic S905W 64bits Quad-Core Cortex-A53@1.5GHz
GPU 	        Penta-core ARM® Mali™-450
RAM 	        1G
ROM 	        8G
WIFI 	        Wi-Fi 802.11 b/g/n
Memory Card 	Support TF card, up to 32GB
HOST 	        USB 2.0
Operating System 	Android 7.1
Bluetooth 	    No BT for 1G+8G
Product Size 	100*100*10mm 