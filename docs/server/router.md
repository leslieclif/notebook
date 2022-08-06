# Install DD-WRT
- Override custom TP-LINK software from your router, use [TFTP](/service) service on a Network LAN server.
- You need to set up a TFTP Server on your computer with IP 192.168.0.66.
- You can do this by linking the MAC address of the computer with the 192.168.0.66 IP and restart the WI-FI connection.
- Verify if the computer has the correct IP.
- Once verified, copy the DD-WRT software to `/tftpboot` directory on the computer.
- Rename the file from `tl-wr841nd-webflash.bin` to `tlwr841nv10_recovery.bin`.
- Shutdown the router and connect the WAN port to main router.
- Hold down the Reset button on the back of the router and switch it on again,
release the reset button when there pop-up a flashing window.
- Wait for the router to connect to the TFTP service and download the recovery.bin file.
- This will kickstart the router installation process. Wait for 10 mins for the process to complete.
- Now using the LAN port, connect the router to the computer and access the IP assigned by the main router to start DD-WRT configuration.

https://wiki.dd-wrt.com/wiki/index.php/Separate_LAN_and_WLAN
https://wiki.dd-wrt.com/wiki/index.php/Multiple_WLANs#Command_Method
https://wiki.dd-wrt.com/wiki/index.php/Linking_Subnets_with_Static_Routes
