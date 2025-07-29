#!/usr/bin/env dash

# ==============================================================================
# test01.sh
# Tests for the 'd' command: line number, regex match, $, ranges, global
# Written by: Ziyi Shi
# Date: 2025-04-20
# For COMP2041/9044 Assignment 2
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: Delete line 2
# -------------------------------
cat > input1.txt <<EOF
a
b
c
EOF

cat > expected1.txt <<EOF
a
c
EOF

pied.py '2d' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2d'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Delete by regex match (/foo/d)
# -------------------------------
cat > input2.txt <<EOF
hello
foo bar
bye
EOF

cat > expected2.txt <<EOF
hello
bye
EOF

pied.py '/foo/d' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/foo/d'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Delete last line ($d)
# -------------------------------
cat > input3.txt <<EOF
first
middle
last
EOF

cat > expected3.txt <<EOF
first
middle
EOF

pied.py '$d' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '\$d'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Global delete (d) — remove all lines
# -------------------------------
cat > input4.txt <<EOF
x
y
z
EOF

cat > expected4.txt <<EOF
EOF

pied.py 'd' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: 'd'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Delete line range (2,3d)
# -------------------------------
cat > input5.txt <<EOF
L1
L2
L3
L4
EOF

cat > expected5.txt <<EOF
L1
L4
EOF

pied.py '2,3d' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '2,3d'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Mixed range: /foo/,/bar/d
# -------------------------------
cat > input6.txt <<EOF
aa
foo line
keep
bar line
zz
EOF

cat > expected6.txt <<EOF
aa
zz
EOF

pied.py '/foo/,/bar/d' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '/foo/,/bar/d'"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All d-command tests passed."
    exit 0
else
    echo "Some d-command tests failed."
    exit 1
fi
