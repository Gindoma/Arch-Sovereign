# V43 Testing Checklist

## Pre-Test Setup

- [ ] Boot into Arch ISO in VM
- [ ] Copy install-v43.sh to VM
- [ ] Verify script is executable: `chmod +x install-v43.sh`
- [ ] Have screenshot tool ready to capture any errors

## Phase 1 Test (INITIALIZATION)

Expected behavior:
- [ ] Script starts with V43 banner
- [ ] Pacman configuration succeeds silently
- [ ] Task 1: "Checking Internet Connection" completes with ✓
- [ ] Task 2: "Initializing Pacman Keys" completes with ✓
- [ ] Task 3: "Syncing Package Databases" completes with ✓
- [ ] NO errors about "input cannot be empty"
- [ ] NO errors about "must be a number"
- [ ] Phase 1 transitions cleanly to Phase 2

## Phase 2 Test (CONFIGURATION WIZARD)

### Disk Selection
- [ ] "Available Disks" header displays
- [ ] At least one disk is listed (e.g., [1] /dev/vda 20G)
- [ ] DEBUG message shows: "DEBUG: Found X disk(s)"
- [ ] Prompt appears: "Select disk number (1-X):"

### Invalid Input Testing
- [ ] Enter empty string → Shows "✗ Input cannot be empty" → Prompt reappears
- [ ] Enter letter "a" → Shows "✗ Must be a number" → Prompt reappears
- [ ] Enter "0" → Shows "✗ Must be between 1 and X" → Prompt reappears
- [ ] Enter "999" → Shows "✗ Must be between 1 and X" → Prompt reappears
- [ ] **CRITICAL**: Script DOES NOT CRASH after any invalid input

### Valid Input Testing
- [ ] Enter "1" → Shows "Selected: /dev/vda (20G)" in green
- [ ] Proceeds to hostname prompt

### Hostname
- [ ] Prompt appears for hostname
- [ ] Test invalid: "my host" (space) → Error, retry works
- [ ] Test valid: "archvm" → Accepts, proceeds

### Username
- [ ] Prompt appears for username
- [ ] Test invalid: "Root" (uppercase) → Error, retry works
- [ ] Test invalid: "root" (reserved) → Error, retry works
- [ ] Test valid: "alice" → Accepts, proceeds

### Passwords
- [ ] Root password prompt appears
- [ ] Test weak password → Warning, can choose to retry
- [ ] Test mismatch → Error, retry works
- [ ] Test strong password (12+ chars, mixed case, numbers) → Accepts

### Partition Sizes
- [ ] SWAP prompt: Test invalid (0, 999) → Errors, retry works
- [ ] SWAP prompt: Enter valid (8) → Accepts
- [ ] ROOT prompt: Test <60GB → Warning, can proceed or retry
- [ ] ROOT prompt: Enter valid (60) → Accepts

### VM Detection & LUKS
- [ ] VM question: Answer "y"
- [ ] LUKS password prompt appears
- [ ] Test mismatch → Error, retry works
- [ ] Test strong password → Accepts

## Phase 3 Test (CONFIRMATION)

- [ ] Summary displays all entered values correctly
- [ ] Test entering "yes" (lowercase) → Aborts
- [ ] Restart, enter "YES" (uppercase) → Proceeds

## Phase 4-9 Test (Installation)

- [ ] Phase 4: Disk partitioning completes
- [ ] LUKS encryption succeeds
- [ ] Phase 5: LVM volumes created
- [ ] Package download starts
- [ ] Phase 6: Filesystems formatted and mounted
- [ ] Phase 7: Base system installs (cinema mode)
- [ ] Phase 8: Configuration applied in chroot
- [ ] Phase 9: Success message with timing

## Critical Success Criteria

### MUST PASS
1. ✅ Phase 1 completes without crashes
2. ✅ Invalid disk numbers don't crash the script
3. ✅ Validation errors allow retry (no script exit)
4. ✅ User can enter values multiple times if they make mistakes
5. ✅ Script completes full installation to Phase 9

### BONUS (Nice to Have)
6. ⭐ Debug output shows disk count
7. ⭐ Error messages are clear and helpful
8. ⭐ Installation completes in <10 minutes (VM)
9. ⭐ System boots successfully after installation

## Error Documentation

If any test fails, document:

1. **Exact Phase**: Which phase number/name
2. **Exact Error**: Screenshot or copy exact error text
3. **Last Success**: What was the last successful operation
4. **Input Given**: What input triggered the error
5. **Reproducible**: Can you trigger it again with same input?

## Expected Differences from V42

| Test | V42 Behavior | V43 Behavior |
|------|--------------|--------------|
| Empty disk input | CRASH | Shows error, retry |
| Invalid number | CRASH | Shows error, retry |
| Phase 1 completion | Sometimes crashes | Always succeeds |
| Validation loops | Cannot retry | Can retry infinitely |
| Error visibility | Hidden/cryptic | Clear with context |

## Quick Test (Minimal)

If you're short on time, at minimum test:

1. Run script
2. Wait for Phase 1 to complete (should succeed)
3. Enter invalid disk number (e.g., "abc")
4. Verify script DOES NOT CRASH
5. Enter valid disk number
6. Verify it proceeds to hostname

If these 6 steps succeed, V43 is fixed.

## Success Criteria

**PASS**: Script allows invalid input retry without crashing

**FAIL**: Script crashes on invalid input (same as V42)

## Reporting Results

When done, report:

1. ✅ PASS or ❌ FAIL
2. Which tests passed/failed
3. Screenshots of any failures
4. Whether installation completed successfully

## Emergency Rollback

If V43 fails worse than V42:

```bash
# Use V42
bash /path/to/install-v42.sh

# Or manual installation
# Follow Arch Wiki manual installation guide
```

## Notes

- Test in VM first (safe, can snapshot/rollback)
- Keep screenshots of each phase for debugging
- The script now has explicit error handling instead of relying on `set -e`
- Validation functions can safely return 1 without killing the script
- Log file is at `/tmp/arch-install.log` if you need detailed traces
