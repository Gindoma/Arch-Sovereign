# Installer Troubleshooting Guide

## Quick Fix for v41 Bug

If you're experiencing "input cannot be empty" errors with v41, use v42 instead:

```bash
cd /home/itachi/Projekte/Arch-Sovereign/install_script
sudo ./install-v42.sh
```

---

## Common Issues

### 1. "No disks found" Error

**Symptom**: Script exits with message about no disks found

**Cause**:
- VM: Virtual disk not attached or recognized
- Bare metal: Disk is mounted or in use
- Device naming: Disk is filtered out by lsblk exclusions

**Solution**:

```bash
# Check what disks are visible
lsblk -d -n -o NAME,SIZE,MODEL,TYPE

# If no output, check ALL devices
lsblk

# For VMs, ensure virtual disk is attached in hypervisor settings
# For bare metal, ensure disk is connected and recognized by BIOS
```

### 2. "Input cannot be empty" Before Any Prompt

**Symptom**: Error appears before you can type anything

**Cause**: You're using v41 (buggy version)

**Solution**: Use v42 instead

```bash
sudo /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh
```

### 3. "Must be a number" Before Any Prompt

**Symptom**: Error appears before you can type anything

**Cause**: You're using v41 with an empty disk list

**Solution**: Use v42, which handles this gracefully

### 4. Validation Fails Immediately

**Symptom**: You enter valid input but it's rejected

**Cause**: Could be terminal encoding or whitespace issues

**Solution**:
```bash
# Ensure you're using a clean bash shell
bash --login

# Run the script in a new session
sudo bash /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh
```

### 5. Script Crashes During Disk Selection

**Symptom**: Script exits or freezes when selecting disk

**Cause**: Disk list is empty or invalid

**Solution**:
```bash
# Manually check disk availability
lsblk -d -n -o NAME,SIZE,MODEL,TYPE -e 7,11

# If command returns nothing, you need to attach/enable a disk
# For VMs: Check hypervisor settings
# For bare metal: Check BIOS/UEFI settings
```

### 6. LUKS Encryption Fails

**Symptom**: "Failed to setup encryption" or similar

**Cause**:
- Partition not properly created
- Insufficient permissions
- Disk is busy/mounted

**Solution**:
```bash
# Check if anything is using the disk
lsblk
mount | grep /dev/sdX  # Replace sdX with your disk

# Unmount if needed
sudo umount /dev/sdX*

# Close any existing encryption
sudo cryptsetup close cryptlvm

# Deactivate LVM
sudo vgchange -an

# Disable swap
sudo swapoff -a

# Restart the installer
```

### 7. pacstrap Fails

**Symptom**: Package installation fails

**Cause**:
- No internet connection
- Mirror issues
- Package database out of sync

**Solution**:
```bash
# Test internet
ping -c 3 google.com

# Update mirrors (on live ISO)
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Sync database
pacman -Sy

# Restart installer
```

### 8. Script Hangs on Package Download

**Symptom**: Spinner keeps spinning but nothing happens

**Cause**: Mirror is slow or unreachable

**Solution**:
```bash
# Press Ctrl+C to cancel
# Update mirrors before running installer
reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Or disable parallel download in script temporarily
# Edit install-v42.sh and comment out line 505-506
```

### 9. Permission Denied Errors

**Symptom**: "Permission denied" when running script

**Solution**:
```bash
# Ensure script is executable
chmod +x /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh

# Run with sudo
sudo /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh

# Or as root
su -
/home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh
```

### 10. LazyVim Clone Fails

**Symptom**: Warning about LazyVim not being set up

**Cause**: No internet or GitHub unreachable

**Impact**: Non-critical - Neovim will still work, just without LazyVim config

**Solution**:
```bash
# Install manually after installation completes
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

---

## VM-Specific Issues

### VirtualBox

**Issue**: No disks found

**Solution**:
1. Power off VM
2. Settings → Storage → Add new disk
3. Ensure disk is set as primary IDE/SATA controller
4. Boot VM and run installer

### VMware

**Issue**: Disk not recognized

**Solution**:
1. Ensure VM has SCSI or SATA disk attached
2. Use UEFI boot mode (not legacy BIOS)
3. Allocate at least 50GB for meaningful installation

### QEMU/KVM

**Issue**: Virtual disk not showing

**Solution**:
```bash
# Ensure virtio drivers are loaded
lsmod | grep virtio

# Check disk with different options
lsblk -d
fdisk -l

# Make sure disk is attached with virtio-blk or virtio-scsi
```

---

## Verification Commands

Before running the installer, verify your environment:

```bash
# Check you're booted in UEFI mode
ls /sys/firmware/efi/efivars
# Should list files. If error, you're in BIOS mode (may need to change VM/BIOS settings)

# Check internet connectivity
ping -c 3 archlinux.org

# Check disk availability
lsblk -d -n -o NAME,SIZE,MODEL,TYPE -e 7,11
# Should show at least one disk

# Check available space
df -h

# Verify you're running as root
whoami
# Should output: root
```

---

## Debug Mode

To run installer with maximum verbosity:

```bash
# Edit install-v42.sh and add at top (line 3):
set -x  # Enable debug mode

# Or run with bash -x
sudo bash -x /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh
```

---

## Log File Location

All operations are logged to:
```
/tmp/arch-install.log
```

To view in real-time:
```bash
# In another terminal (Ctrl+Alt+F2)
tail -f /tmp/arch-install.log
```

---

## Getting Help

If issues persist:

1. **Check the log**: `cat /tmp/arch-install.log | tail -50`
2. **Read the bug analysis**: `/home/itachi/Projekte/Arch-Sovereign/install_script/BUG_ANALYSIS_V41.md`
3. **Compare versions**: `/home/itachi/Projekte/Arch-Sovereign/install_script/CHANGES_V41_TO_V42.md`
4. **Verify prerequisites**: Ensure you meet minimum requirements
   - UEFI system (not legacy BIOS)
   - At least 50GB disk space
   - Active internet connection
   - Booted from Arch ISO

---

## Emergency Recovery

If script fails mid-installation:

```bash
# Unmount everything
umount -R /mnt

# Close encryption
cryptsetup close cryptlvm

# Deactivate LVM
vgchange -an vg0
pvremove /dev/sdX2  # Replace X with your disk

# Turn off swap
swapoff -a

# Now you can safely start over or reboot
reboot
```

---

## Version Compatibility

- **v41**: Buggy, don't use
- **v42**: Current stable version, use this
- **Future versions**: Will maintain backward compatibility with config format

---

## Known Limitations

1. **UEFI Only**: Script doesn't support legacy BIOS boot
2. **Single Disk**: Doesn't handle multi-disk setups
3. **No Dual Boot**: Will wipe entire disk (no Windows dual-boot)
4. **AMD Focus**: Optimized for AMD hardware (works on Intel but not optimized)
5. **No Desktop Environment**: Installs TTY only (Hyprland can be added post-install)

---

## Post-Installation Issues

### 1. Can't Boot After Installation

**Solution**:
```bash
# Boot from Arch ISO again
# Mount your system
cryptsetup open /dev/sdX2 cryptlvm
mount /dev/vg0/root /mnt
mount /dev/sdX1 /mnt/boot

# Chroot in
arch-chroot /mnt

# Reinstall GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
reboot
```

### 2. Network Not Working After Boot

**Solution**:
```bash
# Enable and start NetworkManager
sudo systemctl enable --now NetworkManager

# Connect to WiFi (if applicable)
nmtui
```

### 3. Can't Login

**Cause**: Forgot password or user not created

**Solution**:
```bash
# Boot from Arch ISO
# Mount and chroot (see above)

# Reset password
passwd root
passwd your_username

# Exit and reboot
```

---

## Contact & Support

- **Documentation**: `/home/itachi/Projekte/Arch-Sovereign/install_script/`
- **Bug Reports**: Include `/tmp/arch-install.log` content
- **Feature Requests**: Describe desired functionality

---

**Last Updated**: 2025-11-17
**Applies to**: install-v42.sh and later
