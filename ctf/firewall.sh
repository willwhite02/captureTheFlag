echo "Firewall Starting..."
#Clear all rules
sudo /usr/sbin/iptables --flush
#Make sure syn cookies are on
sudo /usr/sbin/sysctl net.ipv4.tcp_syncookies=1
#Ignores all udp and icmp traffic
sudo /usr/sbin/iptables -A INPUT -i eth0 -p udp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth0 -p udp -j DROP
#sudo /usr/sbin/iptables -A INPUT -i $ETH -p icmp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth0 -p icmp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth0 -p icmp -j DROP
sudo /usr/sbin/iptables -A OUTPUT -o eth0 -p udp -j DROP
sudo /usr/sbin/iptables -A OUTPUT -o eth0 -p udp -j DROP
#Ignores all udp and icmp traffic
sudo /usr/sbin/iptables -A INPUT -i eth1 -p udp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth1 -p udp -j DROP
#sudo /usr/sbin/iptables -A INPUT -i $ETH -p icmp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth1 -p icmp -j DROP
sudo /usr/sbin/iptables -A INPUT -i eth1 -p icmp -j DROP
sudo /usr/sbin/iptables -A OUTPUT -o eth1 -p udp -j DROP
sudo /usr/sbin/iptables -A OUTPUT -o eth1 -p udp -j DROP
#sudo /usr/sbin/iptables -A OUTPUT -o $ETH -p udp -j DROP
#Blocks null packets
sudo /usr/sbin/iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
#Blocks XMAS packets
sudo /usr/sbin/iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
#Ignores internal packets in the server (server and gateway)
sudo /usr/sbin/iptables -A INPUT -s gateway -j DROP
#Block syn flood attack
sudo /usr/sbin/iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
#Block new packets that are not syn
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
#block teardrop
sudo /usr/sbin/iptables -A INPUT -p UDP -f -j DROP
sudo /usr/sbin/iptables -A OUTPUT -p UDP -f -j DROP
sudo /usr/sbin/iptables -A INPUT -p UDP -m length --length 1500 -j DROP
sudo /usr/sbin/iptables -A INPUT -p UDP -m length --length 58 -j DROP
sudo /usr/sbin/iptables -A OUTPUT -p UDP -m length --length 1500 -j DROP
sudo /usr/sbin/iptables -A OUTPUT -p UDP -m length --length 58 -j DROP
#Block packets with invalid tcp flags
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
#sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,ACK -j DROP
#sudo /usr/sbin/iptables -A INPUT -i eth4 -p tcp --tcp-flags SYN ACK -j DROP
#sudo /usr/sbin/iptables -A INPUT -i eth2 -p tcp --tcp-flags SYN ACK -j DROP
#sudo /usr/sbin/iptables -A INPUT -i eth4 -p tcp --tcp-flags SYN ACK -j DROP
#sudo /usr/sbin/iptables -A INPUT -i eth2 -p tcp --tcp-flags SYN ACK -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
sudo /usr/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
#Sockstress defense
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 2 --hitcount 4 -j DROP
#Maybe stop spoofing
sudo /usr/sbin/iptables -t mangle -I PREROUTING -p tcp -m tcp --dport 80 -m state --state NEW -m tcpmss ! --mss 536:65535 -j DROP
#Defend against Sloloris
sudo /usr/sbin/iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 -j DROP
#Prevent DoS attacks
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 80 -m limit --limit 3/s -j ACCEPT
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 22 -m limit --limit 3/s -j ACCEPT
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 443 -m limit --limit 3/s -j ACCEPT
#Accepts new tcp connections
IFACES=("eth0" "eth1")
for iface in "${IFACES[@]}"; do
    sudo /usr/sbin/iptables -A INPUT -s client1 -i "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client1 -i "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client1 -i "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client1 -o "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client1 -o "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client1 -o "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client2 -i "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client2 -i "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client2 -i "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client2 -o "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client2 -o "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client2 -o "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client3 -i "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client3 -i "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client3 -i "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client3 -o "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client3 -o "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client3 -o "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s server -i "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s server -i "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s server -i "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d server -o "$iface" -m state --state NEW -p tcp --dport 22 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d server -o "$iface" -m state --state NEW -p tcp --dport 80 -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d server -o "$iface" -m state --state NEW -p tcp --dport 443 -j ACCEPT
    #Allows traffic to pass from previously accepted connection
    sudo /usr/sbin/iptables -A INPUT -s client1 -i "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client1 -o "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client2 -i "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client2 -o "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s client3 -i "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d client3 -o "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A INPUT -s server -i "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo /usr/sbin/iptables -A OUTPUT -d server -o "$iface" -m state --state RELATED,ESTABLISHED -j ACCEPT
done
# Allow established and related connections to persist
sudo /usr/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo /usr/sbin/iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT  # SSH
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT  # HTTP
sudo /usr/sbin/iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT  # HTTPS
sudo /usr/sbin/iptables -A OUTPUT -p udp --dport 53 -j ACCEPT  # DNS UDP
sudo /usr/sbin/iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT  # DNS TCP
sudo /usr/sbin/iptables -P INPUT DROP
sudo /usr/sbin/iptables -P FORWARD DROP
sudo /usr/sbin/iptables -P OUTPUT DROP
# sudo /usr/sbin/iptables --flush
echo "Firewall Active!!!"