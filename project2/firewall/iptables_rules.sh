# ensure this file has chmod +x iptables_rules.sh ran so that it actually updates the iptables
sudo iptables -F
sudo iptables -X
sudo iptables -x nat -F
sudo iptables -t nat -X

sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

# enable gateway forwarding traffic to external networks (from project 1)
sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE

# mask ip of the server 
sudo iptables -t nat -A POSTROUTING -s 10.0.0.10 -o enp0s8 -j MASQUERADE

# allow reouting to the webserver from the client 
sudo iptables -t nat -A PREROUTING -o enp0s9 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.10:80
# forward traffic from the client to the webserver
sudo iptables -A FORWARD -s 192.168.0.10 -d 10.0.0.10 -p tcp --dport 80 -j ACCEPT

# allow for client to access server for ftp connections
# open ports for ftp 
sudo iptables -A FORWARD -p tcp --dport 30000:30099 -j ACCEPT
sudo iptables -A FORWARD -p tcp --sport 30000:30099 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 21 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 20 -j ACCEPT
sudo iptables -A FORWARD -p tcp --sport 21 -j ACCEPT
sudo iptables -A FORWARD -p tcp --sport 20 -j ACCEPT

# allow ftp routing between server and client
sudo iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 21 -j DNAT --to-destination 192.168.0.10

# allow for ssh to server from client
sudo iptables -A FORWARD -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -p tcp --sport 22 -j ACCEPT

# allow for pings between server and client
iptables -A FORWARD -p icmp -d 10.0.0.10 -j ACCEPT
iptables -A FORWARD -p icmp -d 192.168.0.10 -j ACCEPT

# allow for 8.8.8.8 pings
iptables -A FORWARD -p icmp -d 8.8.8.8 -j ACCEPT
iptables -A INPUT -p icmp -i enp0s9 -j ACCEPT
iptables -A OUTPUT -p icmp -d 8.8.8.8 -j ACCEPT
# allow for outbound tcp packets to http and https
sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
# allow inbound calls for http and https
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 443 -j ACCEPT

# allow for packets from inside the network to send https and ssh requests
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# allow for inbound and outbound udp
sudo iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT

