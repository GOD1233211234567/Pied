#!/usr/bin/env dash

# ==============================================================================
# test06.sh
# Tests for the 'q' (quit) command: by line number, regex, interaction with d
# Written by: Ziyi Shi
# Date: 2025-04-22
# For COMP2041/9044 Assignment 2
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: Quit after line 2
# -------------------------------
cat > input1.txt <<EOF
one
two
three
four
EOF

cat > expected1.txt <<EOF
one
two
EOF

pied.py '2q' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2q'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Quit on matching /stop/
# -------------------------------
cat > input2.txt <<EOF
start
working
stop now
should not see this
EOF

cat > expected2.txt <<EOF
start
working
stop now
EOF

pied.py '/stop/q' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/stop/q'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Delete line 2 and quit at line 4
# -------------------------------
cat > input3.txt <<EOF
a
b
c
d
e
EOF

cat > expected3.txt <<EOF
a
c
d
EOF

pied.py '2d; 4q' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '2d; 4q'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Delete line 2, then quit on line 2 (originally 3rd)
# -------------------------------
cat > input4.txt <<EOF
first
second
third
fourth
EOF

cat > expected4.txt <<EOF
first
third
EOF

pied.py '2d; 2q' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: '2d; 2q'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Quit condition never matched, should read all lines
# -------------------------------
cat > input5.txt <<EOF
aaa
bbb
ccc
EOF

cat > expected5.txt <<EOF
aaa
bbb
ccc
EOF

pied.py '/notfound/q' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '/notfound/q'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Multiple files, quit on line 2
# -------------------------------
cat > fileA.txt <<EOF
a1
a2
a3
EOF

cat > fileB.txt <<EOF
b1
b2
EOF

cat > expected6.txt <<EOF
a1
a2
EOF

pied.py '2q' fileA.txt fileB.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1
