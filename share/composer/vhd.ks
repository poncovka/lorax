# Lorax Composer VHD (Azure, Hyper-V) output kickstart template

# Add a separate /boot partition
part /boot --size=1024

# Firewall configuration
firewall --enabled

# NOTE: The root account is locked by default
user --name composer --plaintext --password composer --groups=wheel
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
bootloader --location=mbr --append="no_timer_check console=ttyS0,115200n8 earlyprintk=ttyS0,115200 rootdelay=300 net.ifnames=0 biosdevname=0"

# Basic services
services --enabled=sshd,chronyd,waagent

%post

# Set a verbose boot theme.
plymouth-set-default-theme details

# Add Hyper-V modules into initramfs
cat > /etc/dracut.conf.d/10-hyperv.conf << EOF
add_drivers+=" hv_vmbus hv_netvsc hv_storvsc "
EOF

dracut -f -v --persistent-policy by-uuid

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
WALinuxAgent

# NOTE lorax-composer will add the recipe packages below here, including the final %end
