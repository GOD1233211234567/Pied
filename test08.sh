#!/usr/bin/env dash

# ==============================================================================
# test08.sh
# Tests for complex command combinations: i, a, p, s, d, c, q in sequence
# Written by: Ziyi Shi
# Date: 2025-04-23
# For COMP2041/9044 Assignment 2
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: i + a + p
# -------------------------------
cat > input1.txt <<EOF
center
EOF

cat > expected1.txt <<EOF
TOP
center
center
BOTTOM
EOF

pied.py '-n 1i TOP; 1a BOTTOM; 1p' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: 'i + a + p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: s + p
# -------------------------------
cat > input2.txt <<EOF
I like apples.
EOF

cat > expected2.txt <<EOF
I like apples.
I love apples.
EOF

pied.py '-n s/like/love/; p' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: 's + p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: c + p — replaced line should override p
# -------------------------------
cat > input3.txt <<EOF
aaa
EOF

cat > expected3.txt <<EOF
XXX
EOF

pied.py '-n c XXX; p' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: 'c + p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: d + p — deleted lines should not print even if marked p
# -------------------------------
cat > input4.txt <<EOF
1
2
3
EOF

cat > expected4.txt <<EOF
1
3
3
EOF

pied.py '-n 2d; 3p' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: 'd + p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: q + a — early quit should prevent appending
# -------------------------------
cat > input5.txt <<EOF
one
two
three
EOF

cat > expected5.txt <<EOF
one
two
EOF

pied.py '2q; 2a XXX' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: 'q + a (should stop before append)'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: full pipeline — i, s, c, d, a, p combo
# -------------------------------
cat > input6.txt <<EOF
raw line
delete me
good line
EOF

cat > expected6.txt <<EOF
>>> inserted
REPLACED
REPLACED
good line
good line
*** appended
EOF

pied.py '-n 1i >>> inserted; 1s/raw/REPLACED/; 2d; 1c REPLACED; 3a *** appended; 3p' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: full combo"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All combination command tests passed."
    exit 0
else
    echo "Some combination command tests failed."
    exit 1
fi
