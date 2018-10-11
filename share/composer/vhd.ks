# Lorax Composer VHD (Azure, Hyper-V) output kickstart template

# Add a separate /boot partition
part /boot --size=1024

# Firewall configuration
firewall --disabled

# NOTE: The root account is locked by default
user --name composer --plaintext --password composer
# Network information
network  --bootproto=dhcp --onboot=on --activate
# System keyboard
keyboard --xlayouts=us --vckeymap=us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --permissive
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
lsblk
cat /etc/fstab

# Set up network.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

cat /etc/sysconfig/network

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

cat /etc/sysconfig/network-scripts/ifcfg-eth0

rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /etc/udev/rules.d/75-persistent-net-generator.rules

# Set a verbose boot theme.
plymouth-set-default-theme details

# Add Hyper-V modules into initramfs
cat > /etc/dracut.conf.d/10-hyperv.conf << EOF
add_drivers+=" hv_vmbus hv_netvsc hv_storvsc "
EOF

dracut -f -v --persistent-policy by-uuid

lsinitrd | grep hv

# Set up the waagent.
cat >> /etc/waagent.conf << EOF
Provisioning.Enabled=n
Provisioning.UseCloudInit=y
EOF

cat /etc/waagent.conf

# Remove random-seed
rm /var/lib/systemd/random-seed

# Clear /etc/machine-id
rm /etc/machine-id
touch /etc/machine-id

%end

%packages
kernel
-dracut-config-rescue

grub2

chrony
cloud-init
WALinuxAgent

# NOTE lorax-composer will add the recipe packages below here, including the final %end
