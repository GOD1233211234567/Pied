#!/usr/bin/env dash

# ==============================================================================
# test07.sh
# Tests for the '-n' flag behavior: suppress default output, control with 'p'
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
# Case 1: -n + 2p — only line 2 is printed
# -------------------------------
cat > input1.txt <<EOF
apple
banana
cherry
EOF

cat > expected1.txt <<EOF
banana
banana
EOF

pied.py '-n 2p' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '-n 2p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: -n + /ana/p — regex match only
# -------------------------------
cat > input2.txt <<EOF
foo
banana
bar
EOF

cat > expected2.txt <<EOF
banana
banana
EOF

pied.py '-n /ana/p' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '-n /ana/p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: -n + 2p + s on line 2
# -------------------------------
cat > input3.txt <<EOF
red
blue
green
EOF

cat > expected3.txt <<EOF
blue
BLU
EOF

pied.py '-n 2p; 2s/blue/BLU/' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '-n 2p; 2s/blue/BLU/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: -n + s only, no p — should not print anything
# -------------------------------
cat > input4.txt <<EOF
a = 1
b = 2
EOF

cat > expected4.txt <<EOF
EOF

pied.py '-n s/=/:/' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: '-n s/=/:/' without p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: -n + p + s globally
# -------------------------------
cat > input5.txt <<EOF
x = 1
y = 2
z = 3
EOF

cat > expected5.txt <<EOF
x = 1
x : 1
y = 2
y : 2
z = 3
z : 3
EOF

pied.py '-n p; s/=/ : /g' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '-n p; s/=/ : /g'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: -n only, no p — suppress all output
# -------------------------------
cat > input6.txt <<EOF
111
222
333
EOF

cat > expected6.txt <<EOF
EOF

pied.py '-n' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '-n' without any p"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All -n mode tests passed."
    exit 0
else
    echo "Some -n mode tests failed."
    exit 1
fi
