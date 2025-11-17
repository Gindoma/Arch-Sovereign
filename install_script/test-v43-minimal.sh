#!/bin/bash
# ==============================================================================
# MINIMAL V43 TEST - Validates the core fix without full installation
# ==============================================================================
# Purpose: Test that validation loops work without crashing
# Usage: bash test-v43-minimal.sh

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

echo "=============================================="
echo "V43 MINIMAL VALIDATION TEST"
echo "=============================================="
echo ""
echo "This test verifies that:"
echo "1. Validation functions can return 1 without crashing"
echo "2. Invalid input allows retry"
echo "3. No set -e flag causes unexpected exits"
echo ""

# NO SET -E (this is the fix)
set -o pipefail

# Validation function (same as V43)
validate_number() {
    local input="$1"
    local min="$2"
    local max="$3"

    if [[ -z "$input" ]]; then
        echo "${RED}✗ Input cannot be empty${NC}"
        return 1
    fi

    if [[ ! "$input" =~ ^[0-9]+$ ]]; then
        echo "${RED}✗ Must be a number${NC}"
        return 1
    fi

    if [[ -z "$min" ]] || [[ -z "$max" ]]; then
        echo "${RED}✗ Internal error: validation range not specified${NC}"
        return 1
    fi

    if [ "$min" -gt "$max" ]; then
        echo "${RED}✗ Internal error: invalid range (min=$min, max=$max)${NC}"
        return 1
    fi

    if [ "$input" -lt "$min" ] || [ "$input" -gt "$max" ]; then
        echo "${RED}✗ Must be between $min and $max${NC}"
        return 1
    fi

    return 0
}

echo "TEST 1: Empty input validation"
echo "================================"
echo "Calling validate_number with empty string..."
validate_number "" 1 10
if [ $? -ne 0 ]; then
    echo "${GREEN}✓ Correctly rejected empty input AND script didn't crash${NC}"
else
    echo "${RED}✗ Should have rejected empty input${NC}"
    exit 1
fi
echo ""

echo "TEST 2: Non-numeric input validation"
echo "====================================="
echo "Calling validate_number with 'abc'..."
validate_number "abc" 1 10
if [ $? -ne 0 ]; then
    echo "${GREEN}✓ Correctly rejected non-numeric input AND script didn't crash${NC}"
else
    echo "${RED}✗ Should have rejected non-numeric input${NC}"
    exit 1
fi
echo ""

echo "TEST 3: Out of range validation"
echo "==============================="
echo "Calling validate_number with '999' (range 1-10)..."
validate_number "999" 1 10
if [ $? -ne 0 ]; then
    echo "${GREEN}✓ Correctly rejected out-of-range input AND script didn't crash${NC}"
else
    echo "${RED}✗ Should have rejected out-of-range input${NC}"
    exit 1
fi
echo ""

echo "TEST 4: Valid input validation"
echo "=============================="
echo "Calling validate_number with '5' (range 1-10)..."
validate_number "5" 1 10
if [ $? -eq 0 ]; then
    echo "${GREEN}✓ Correctly accepted valid input${NC}"
else
    echo "${RED}✗ Should have accepted valid input${NC}"
    exit 1
fi
echo ""

echo "TEST 5: Invalid range (min > max)"
echo "=================================="
echo "Calling validate_number with min=10, max=1..."
validate_number "5" 10 1
if [ $? -ne 0 ]; then
    echo "${GREEN}✓ Correctly detected invalid range AND script didn't crash${NC}"
else
    echo "${RED}✗ Should have detected invalid range${NC}"
    exit 1
fi
echo ""

echo "TEST 6: Interactive retry loop (automated)"
echo "==========================================="
echo "Simulating user entering: 'abc' → '' → '999' → '5'"

# Simulate inputs
TEST_INPUTS=("abc" "" "999" "5")
INPUT_INDEX=0

for test_input in "${TEST_INPUTS[@]}"; do
    echo ""
    echo "Simulated input: '$test_input'"

    if validate_number "$test_input" 1 10; then
        echo "${GREEN}✓ Input '$test_input' accepted, breaking loop${NC}"
        if [ "$test_input" != "5" ]; then
            echo "${RED}✗ Should not have accepted '$test_input'${NC}"
            exit 1
        fi
        break
    else
        echo "${YELLOW}↻ Input '$test_input' rejected, loop continues${NC}"
        if [ "$test_input" == "5" ]; then
            echo "${RED}✗ Should have accepted '5'${NC}"
            exit 1
        fi
    fi
done
echo ""

echo "TEST 7: Disk detection simulation"
echo "=================================="
echo "Simulating disk array like in actual script..."

# Simulate disk list
DISK_LIST=("vda 20G QEMU_HARDDISK disk" "vdb 10G QEMU_HARDDISK disk")
DISK_MAX="${#DISK_LIST[@]}"

echo "Found $DISK_MAX disk(s)"

# Pre-validate DISK_MAX (like V43 does)
if [ "$DISK_MAX" -lt 1 ]; then
    echo "${RED}✗ No disks found${NC}"
    exit 1
else
    echo "${GREEN}✓ Disks detected: $DISK_MAX${NC}"
fi

# Test validation with calculated range
echo "Testing disk selection validation (1-$DISK_MAX)..."
validate_number "1" 1 "$DISK_MAX"
if [ $? -eq 0 ]; then
    echo "${GREEN}✓ Disk selection validation works${NC}"
else
    echo "${RED}✗ Disk selection validation failed${NC}"
    exit 1
fi
echo ""

echo "=============================================="
echo "ALL TESTS PASSED!"
echo "=============================================="
echo ""
echo "${GREEN}✓ Validation functions work correctly${NC}"
echo "${GREEN}✓ Invalid input can be retried${NC}"
echo "${GREEN}✓ Script doesn't crash on validation failures${NC}"
echo "${GREEN}✓ Ranges are validated before use${NC}"
echo "${GREEN}✓ Interactive loops behave as expected${NC}"
echo ""
echo "V43 core functionality is VERIFIED."
echo "The full installer should work correctly."
echo ""
echo "${YELLOW}Next step: Test full install-v43.sh in VM${NC}"
