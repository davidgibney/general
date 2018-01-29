# More Linux cheats!


```bash

### KERNEL/SYSTEM INFO
uname -a                          # Get the kernel version (and BSD version)
cat /etc/redhat-release           # Get redhat version
cat /etc/debian_version           # Get Debian version

### HARDWARE
dmesg                                                                     # Detected hardware and boot messages
lsdev                                                                     # information about installed hardware
lspci                                                                     # list PCI-connected devices
dd if=/dev/mem bs=1k skip=768 count=256 2>/dev/null | strings -n 8        # Read BIOS

cat /proc/cpuinfo                                                         # CPU model
cat /proc/meminfo                                                         # Hardware memory
grep MemTotal /proc/meminfo                                               # Display the physical memory
watch -n1 'cat /proc/interrupts'                                          # Watch changeable interrupts continuously
free -m                                                                   # Used and free memory
cat /proc/devices                                                         # Configured devices
lspci -tv                                                                 # Show PCI devices
lsusb -tv                                                                 # Show USB devices
lshal                                                                     # Show a list of all devices with their properties
dmidecode                                                                 # Show DMI/SMBIOS: hw info from the BIOS

### STATS
top                                                     # display and update the top cpu processes
mpstat 1                                                # display processors related statistics
vmstat 2                                                # display virtual memory statistics
iostat 2                                                # display I/O statistics (2 s intervals)

### USERS
id                                                      # Show the active user id with login and group
last                                                    # Show last logins on the system
who                                                     # Show who is logged on the system
groupadd admin                                          # Add group "admin" and user colin (Linux/Solaris)
useradd -c "Colin Barschel" -g admin -m colin
userdel colin                                           # Delete user colin (Linux/Solaris)
pw groupmod admin -m newmember                          # Add a new member to a group
pw useradd colin -c "Colin Barschel"
passwd                                                  # Change password

/etc/passwd
/etc/group

### SYSTEM LIMITS
# Kernel limits are set with sysctl. Permanent limits are set in /etc/sysctl.conf.
sysctl -a                                                       # View all system limits
cat /etc/sysctl.conf
sysctl fs.file-max                                              # View max open files limit
sysctl fs.file-max=102400                                       # Change max open files limit
echo "1024 50000" > /proc/sys/net/ipv4/ip_local_port_range      # port range
fs.file-max=102400                                              # Permanent entry in sysctl.conf
cat /proc/sys/fs/file-nr                                        # How many file descriptors are in use

### RUN-LEVELS

0 Shutdown and halt
1 Single-User mode (also S)
2 Multi-user without network
3 Multi-user with network
5 Multi-user with X
6 Reboot

# init 0



### REPAIR GRUB

Boot from a live cd, find your linux partition under /dev and use fdisk to find
the linux partion, mount the linux partition, add /proc and /dev and use grub-install /dev/xyz.
If linux lies on /dev/sda6...:
mount /dev/sda6 /mnt # mount the linux partition on /mnt
mount --bind /proc /mnt/proc # mount the proc subsystem into /mnt
mount --bind /dev /mnt/dev # mount the devices into /mnt
chroot /mnt # change root to the linux partition
grub-install /dev/sda # reinstall grub with your old settings




```
