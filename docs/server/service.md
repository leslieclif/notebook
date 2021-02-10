# Create a systemd unit file for starting the application:

Example service file can be found here:
```BASH
$ wget https://gist.githubusercontent.com/Artemmkin/ce82397cfc69d912df9cd648a8d69bec/raw/7193a36c9661c6b90e7e482d256865f085a853f2/raddit.service
```
Move it to the systemd directory
```BASH
$ sudo mv raddit.service /etc/systemd/system/raddit.service
```
Now start the application and enable autostart:
```BASH
$ sudo systemctl start raddit
$ sudo systemctl enable raddit
```
Verify that it's running:
```BASH
$ sudo systemctl status raddit
```