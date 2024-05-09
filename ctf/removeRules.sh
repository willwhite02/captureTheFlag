echo "Removing rules..."
sudo /usr/sbin/iptables -P INPUT ACCEPT
sudo /usr/sbin/iptables -P FORWARD ACCEPT
sudo /usr/sbin/iptables -P OUTPUT ACCEPT
sudo /usr/sbin/iptables --flush
echo "Rules removed successfully."