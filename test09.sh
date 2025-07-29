#!/usr/bin/env dash

# ==============================================================================
# test09.sh
# Tests for edge cases, empty input, invalid patterns, special symbols, no matches
# Written by: Ziyi Shi
# Date: 2025-04-24
# For COMP2041/9044 Assignment 2
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: Empty file should produce no output
# -------------------------------
touch input1.txt
touch expected1.txt

pied.py 'p' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: empty file input"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: File of only empty lines
# -------------------------------
cat > input2.txt <<EOF


EOF

cat > expected2.txt <<EOF


EOF

pied.py 'p' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: file with only empty lines"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Invalid regex — should not crash
# -------------------------------
cat > input3.txt <<EOF
abc
def
EOF

cat > expected3.txt <<EOF
abc
def
EOF

pied.py '/[abc/p' input3.txt > actual3.txt 2>/dev/null  # malformed regex

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: invalid regex handling"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Substitution pattern not found — should change nothing
# -------------------------------
cat > input4.txt <<EOF
hello world
EOF

cat > expected4.txt <<EOF
hello world
EOF

pied.py 's/NOTFOUND/replace/' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: unmatched substitution"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: $c on empty file — should not crash
# -------------------------------
touch input5.txt
touch expected5.txt

pied.py '$c last' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: \$c on empty file"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Special characters in replacement
# -------------------------------
cat > input6.txt <<EOF
path/to/file
EOF

cat > expected6.txt <<EOF
path|to|file
EOF

pied.py 's/\//|/g' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: special character substitution"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All edge case tests passed."
    exit 0
else
    echo "Some edge case tests failed."
    exit 1
fi
