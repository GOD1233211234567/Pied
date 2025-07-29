#!/usr/bin/env dash

# ==============================================================================
# test03.sh
# Tests for the 'i' (insert) command: before line N, regex, $, global, edge
# Written by: Ziyi Shi
# Date: 2025-04-21
# For COMP2041/9044 Assignment 2
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: Insert before line 2
# -------------------------------
cat > input1.txt <<EOF
a
b
c
EOF

cat > expected1.txt <<EOF
a
inserted
b
c
EOF

pied.py '2i inserted' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2i inserted'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Insert before line matching regex /target/
# -------------------------------
cat > input2.txt <<EOF
xx
target line
yy
EOF

cat > expected2.txt <<EOF
xx
<before>
target line
yy
EOF

pied.py '/target/i <before>' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/target/i <before>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Insert before last line ($i)
# -------------------------------
cat > input3.txt <<EOF
1
2
3
EOF

cat > expected3.txt <<EOF
1
2
<last-before>
3
EOF

pied.py '$i <last-before>' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '\$i <last-before>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Global insert (before every line)
# -------------------------------
cat > input4.txt <<EOF
one
two
three
EOF

cat > expected4.txt <<EOF
<g>
one
<g>
two
<g>
three
EOF

pied.py 'i <g>' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: 'i <g>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Insert blank line before line 2
# -------------------------------
cat > input5.txt <<EOF
A
B
C
EOF

cat > expected5.txt <<EOF
A

B
C
EOF

pied.py '2i ' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '2i (blank)'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Invalid line number (999i should not crash or insert)
# -------------------------------
cat > input6.txt <<EOF
one
two
EOF

cat > expected6.txt <<EOF
one
two
EOF

pied.py '999i skip' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '999i (invalid index)'"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All i-command tests passed."
    exit 0
else
    echo "Some i-command tests failed."
    exit 1
fi
