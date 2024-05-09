# Fix permissions
sudo chown $USER:$USER /etc/snort/rules/local.rules
sudo chmod +rwx /etc/snort/rules/local.rules

# Append multiple Snort rules to the local rules file
sudo tee -a /etc/snort/rules/local.rules <<'EOF'
alert tcp any any -> $HOME_NET 80 (msg:"Possible HTTP connection"; sid:1000001;)
alert tcp any any -> $HOME_NET 22 (msg:"Possible SSH connection"; sid:1000002;)
alert icmp any any -> $HOME_NET any (msg:"ICMP traffic"; sid:1000003;)
alert tcp any any -> $HOME_NET 443 (msg:"Possible HTTPS connection"; sid:1000004;)
alert udp any any -> $HOME_NET 53 (msg:"Possible DNS traffic"; sid:1000005;)
# More rules can be added here...
EOF

# Test Snort configuration
sudo snort -T -c /etc/snort/snort.conf

# Restart Snort service
sudo systemctl restart snort
# Or if not using systemd:
# sudo service snort restart

echo "Snort rules added and service restarted."