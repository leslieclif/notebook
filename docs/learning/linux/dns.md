[Testing DNS](https://danielmiessler.com/study/tcpdump/)
```BASH
# Install Bind DNS server
apt install bind9 bind9utils bind9-doc -y
systemctl status bind9      # Installs and starts the named service
# named is the actual daemon or service that is executed by bind9
# Change the DNS server to only serve IPv4 adresses
# Update /etc/default/named file and add below config
OPTIONS="-u bind -4"        # -4 for IPV4 and -6 for IPV6
systemctl reload-or-restart bind9   # restart the service
systemctl status bind9

# Testing DNS service
# Login to the DNS server using ssh and execute
dig -t a @localhost google.com      # localhost will use the existing Bind9 service to fetch the DNS answers
# a will give the IP address as answers
dig -t a @1.1.1.1 google.com        # 1.1.1.1 is the public Cloudflare DNS server
dig -t a @localhost parrotlinux.org   # Multiple Nameservers are shown as athorative DNS servers
dig -t ns @localhost cisco.com      # It will give the name servers for cisco
dig -t a @localhost ns1.cisco.com    # It will give the IP address of the nameserver ns1 of cisco

# dig function
dns -> dig +nocmd $1 ANY +multiline +noall +answer
```
# Debug Network calls
```BASH
sudo ss -plnt | grep ':53'          # Check which process is listenng on port 53
```
# SSL
```BASH
# Connect SSL on the server to test SSL
openssl s_client -connect 'localhost:443' -showcerts --servername 'vm.domain.com' -CAfile '/etc/tls.pem'

# Connect SSL by resolving DNS using curl on localhost
curl --resolve vm.domain.com:443:127.0.0.1 https://localhost/ping -key /etc/tls.key
```