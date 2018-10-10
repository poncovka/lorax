# Lorax Composer VHD (Azure, Hyper-V) output kickstart template

# Add a separate /boot partition
part /boot --size=1024

# Firewall configuration
firewall --enabled

# NOTE: The root account is locked by default
# Network information
network  --bootproto=dhcp --onboot=on --activate
# System keyboard
keyboard --xlayouts=us --vckeymap=us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing
# Installation logging level
logging --level=info
# Shutdown after installation
shutdown
# System timezone
timezone  US/Eastern
# System bootloader configuration
bootloader --location=mbr --append="no_timer_check console=ttyS0,115200n8 earlyprintk=ttyS0,115200 rootdelay=300 net.ifnames=0"

# Basic services
services --enabled=sshd,chronyd,waagent,cloud-init

%post
# Remove random-seed
rm /var/lib/systemd/random-seed

# Clear /etc/machine-id
rm /etc/machine-id
touch /etc/machine-id

# Set up network.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

cat >> /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="no"
PEERDNS="yes"
IPV6INIT="no"
NM_CONTROLLED="no"
EOF

rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /etc/udev/rules.d/75-persistent-net-generator.rules

# Enable network.service
systemctl enable network.service

# Set a verbose boot theme.
plymouth-set-default-theme --rebuild-initrd details
%end

%packages
kernel
-dracut-config-rescue

grub2

chrony
cloud-init

# Uninstall NetworkManager, install network.service and WALinuxAgent
-NetworkManager
network-scripts
WALinuxAgent

# NOTE lorax-composer will add the recipe packages below here, including the final %end
