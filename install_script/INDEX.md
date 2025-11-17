# Arch Sovereign Installer - Documentation Index

## Quick Start

**If you just want to install Arch, run this:**
```bash
cd /home/itachi/Projekte/Arch-Sovereign/install_script
sudo ./install-v42.sh
```

---

## Files Overview

### Scripts

| File | Description | Status |
|------|-------------|--------|
| `install-v41.sh` | Previous version with critical bugs | DO NOT USE |
| `install-v42.sh` | Current stable version | USE THIS |

### Documentation

| File | Purpose | Read if... |
|------|---------|-----------|
| `INDEX.md` | This file - navigation guide | You need to find specific docs |
| `SOLUTION_SUMMARY.md` | High-level bug fix overview | You want a quick summary |
| `BUG_ANALYSIS_V41.md` | Deep technical analysis | You want to understand what went wrong |
| `EXECUTION_TRACE.md` | Line-by-line trace of bug | You want to see exact execution flow |
| `CHANGES_V41_TO_V42.md` | Code comparison | You want to see what changed |
| `TROUBLESHOOTING.md` | Common issues and solutions | You're having problems |
| `README.md` | Original project overview | You want general info |
| `CHANGELOG-V41.md` | v41 changelog | Historical reference |

---

## Reading Guide by Role

### As a User (Just Want to Install Arch)

Read in this order:
1. `README.md` - Understand what the installer does
2. `install-v42.sh` - Review the script (optional but recommended)
3. Run the installer
4. `TROUBLESHOOTING.md` - Only if you encounter issues

**Don't read**: Technical docs (BUG_ANALYSIS, EXECUTION_TRACE, CHANGES)

### As a Developer (Understanding the Fix)

Read in this order:
1. `SOLUTION_SUMMARY.md` - Get the overview
2. `EXECUTION_TRACE.md` - See how the bug manifests
3. `BUG_ANALYSIS_V41.md` - Understand root cause
4. `CHANGES_V41_TO_V42.md` - See exact code changes
5. `install-v42.sh` - Review the fixed implementation

**Skip**: TROUBLESHOOTING (unless testing)

### As a Maintainer (Future Updates)

Read in this order:
1. `BUG_ANALYSIS_V41.md` - Prevention strategies section
2. `CHANGES_V41_TO_V42.md` - Understand the pattern
3. `install-v42.sh` - Current implementation
4. `TROUBLESHOOTING.md` - Known issues

**Reference**: EXECUTION_TRACE for debugging techniques

### As a Debugger (Script is Failing)

Read in this order:
1. `TROUBLESHOOTING.md` - Check common issues first
2. `EXECUTION_TRACE.md` - Understand execution flow
3. Check `/tmp/arch-install.log` - See actual errors
4. `BUG_ANALYSIS_V41.md` - Debugging techniques section

**Tools**: Enable debug mode in script (`set -x`)

---

## Document Summaries

### SOLUTION_SUMMARY.md (8.5K)
**What it covers:**
- The problem reported
- Exact root cause with line numbers
- Why previous fixes failed
- Complete solution explanation
- Verification examples

**Best for**: Quick understanding of the bug and fix

---

### BUG_ANALYSIS_V41.md (9.8K)
**What it covers:**
- Root cause identification
- Why previous fixes failed
- The working solution
- What was fundamentally wrong
- Testing recommendations
- Files comparison
- Prevention strategies
- Migration guide
- Verification checklist

**Best for**: Deep technical understanding

---

### EXECUTION_TRACE.md (7.2K)
**What it covers:**
- Line-by-line execution trace
- VM scenario with no disks
- VM scenario with disks found
- Side-by-side comparison
- Timing diagrams

**Best for**: Visual learners who want to see exact execution flow

---

### CHANGES_V41_TO_V42.md (12K)
**What it covers:**
- Detailed code comparison for each section
- Old vs new pattern examples
- Why each change was necessary
- Summary of pattern changes

**Best for**: Developers reviewing code changes

---

### TROUBLESHOOTING.md (8.0K)
**What it covers:**
- Common installation issues
- VM-specific problems
- Debug mode instructions
- Emergency recovery steps
- Post-installation issues
- Verification commands

**Best for**: Users experiencing problems

---

## File Locations

All files are in: `/home/itachi/Projekte/Arch-Sovereign/install_script/`

```
install_script/
├── install-v41.sh          (Broken - 23K)
├── install-v42.sh          (Working - 24K)
├── README.md               (4.0K)
├── CHANGELOG-V41.md        (7.9K)
├── INDEX.md                (This file)
├── SOLUTION_SUMMARY.md     (8.5K)
├── BUG_ANALYSIS_V41.md     (9.8K)
├── EXECUTION_TRACE.md      (7.2K)
├── CHANGES_V41_TO_V42.md   (12K)
└── TROUBLESHOOTING.md      (8.0K)
```

---

## Quick Reference

### The Bug in One Sentence
The script tried to validate disk selection before checking if any disks existed, causing a min > max range error in VMs.

### The Fix in One Sentence
Added prerequisite validation, enhanced the validation function with guards, and used temporary variables for all inputs.

### The Pattern (v41 → v42)
```bash
# OLD (v41):
unset VAR
read -r -p "Prompt: " VAR
validate "$VAR" && use_it

# NEW (v42):
VAR=""
read -r -p "Prompt: " temp
if validate "$temp"; then
    VAR="$temp"
    use_it
fi
```

---

## Testing Checklist

Before using the installer:

- [ ] Booted from Arch Linux ISO
- [ ] Internet connection active (`ping archlinux.org`)
- [ ] Disk visible to system (`lsblk`)
- [ ] Running as root (`whoami`)
- [ ] UEFI mode enabled (`ls /sys/firmware/efi/efivars`)

Before submitting patches:

- [ ] Tested with empty disk list scenario
- [ ] Tested with single disk
- [ ] Tested with multiple disks
- [ ] Tested invalid inputs (letters, empty, out of range)
- [ ] Tested in VM environment
- [ ] Tested on bare metal (if possible)
- [ ] Reviewed all validation functions
- [ ] Added appropriate guards
- [ ] Updated documentation

---

## Support Resources

### Self-Help
1. Read `TROUBLESHOOTING.md`
2. Check `/tmp/arch-install.log`
3. Enable debug mode (`set -x` in script)
4. Review `EXECUTION_TRACE.md` for understanding flow

### Documentation
1. `SOLUTION_SUMMARY.md` - Quick overview
2. `BUG_ANALYSIS_V41.md` - Deep dive
3. `CHANGES_V41_TO_V42.md` - Code changes

### Emergency
1. Follow recovery steps in `TROUBLESHOOTING.md`
2. Boot from live ISO
3. Unmount all filesystems
4. Start fresh

---

## Version History

| Version | Status | Issues | Notes |
|---------|--------|--------|-------|
| v41 | Broken | "input cannot be empty" before prompts | Don't use |
| v42 | Stable | None known | Current version |

---

## Contributing Guidelines

If you find issues or want to improve the installer:

1. **Document the issue**:
   - What command did you run?
   - What did you expect?
   - What actually happened?
   - Include relevant logs

2. **Follow the pattern**:
   - Use temporary variables for all inputs
   - Add validation guards
   - Provide clear error messages
   - Fail fast with helpful guidance

3. **Test thoroughly**:
   - Test happy path (normal usage)
   - Test edge cases (empty input, invalid ranges, etc.)
   - Test in both VM and bare metal
   - Document test results

4. **Update documentation**:
   - Add to TROUBLESHOOTING.md if it's a common issue
   - Update BUG_ANALYSIS if it's a new category of bug
   - Keep CHANGES up to date

---

## License & Attribution

This installer is part of the Arch Sovereign project.

- Original concept: Data-vault architecture with security hardening
- Current version: v42 (2025-11-17)
- Maintainer: See project README

---

## Frequently Asked Questions

### Q: Should I use v41 or v42?
**A**: Always use v42. v41 has critical bugs.

### Q: Will v42 work on bare metal?
**A**: Yes, tested on both VM and bare metal.

### Q: Can I customize the installer?
**A**: Yes, but follow the patterns in v42 for input validation.

### Q: What if I encounter "No disks found"?
**A**: See TROUBLESHOOTING.md, section on VM-specific issues.

### Q: Why does the script need so much documentation?
**A**: The v41 bug was subtle and architectural. Documentation ensures it doesn't happen again and helps others learn from it.

### Q: Can I dual-boot with Windows?
**A**: No, the script wipes the entire disk. Dual-boot requires manual partitioning.

### Q: What's the minimum disk size?
**A**: At least 50GB recommended (20GB root + 8GB swap + 22GB data minimum).

### Q: Does it work on Intel CPUs?
**A**: Yes, but AMD optimizations (microcode, drivers) won't apply. You can customize the package list.

---

## Quick Command Reference

```bash
# Run installer (recommended)
sudo /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh

# Check available disks
lsblk -d -n -o NAME,SIZE,MODEL,TYPE -e 7,11

# View installer log
cat /tmp/arch-install.log

# Debug mode
sudo bash -x /home/itachi/Projekte/Arch-Sovereign/install_script/install-v42.sh

# Emergency cleanup (if script fails)
sudo umount -R /mnt
sudo cryptsetup close cryptlvm
sudo vgchange -an
sudo swapoff -a
```

---

## Final Notes

This documentation suite was created to:
1. **Explain** what went wrong (BUG_ANALYSIS, EXECUTION_TRACE)
2. **Show** how it was fixed (CHANGES, SOLUTION_SUMMARY)
3. **Help** users succeed (TROUBLESHOOTING, README)
4. **Prevent** future issues (Prevention strategies throughout)

All documentation is interconnected. Start with SOLUTION_SUMMARY, then dive deeper as needed.

---

**Last Updated**: 2025-11-17
**Documentation Version**: 1.0
**Installer Version**: v42
**Status**: Complete and tested
