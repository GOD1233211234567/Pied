#!/usr/bin/env dash

# ==============================================================================
# test04.sh
# Tests for the 'a' (append) command: after line N, regex, $, global, edge cases
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
# Case 1: Append after line 2
# -------------------------------
cat > input1.txt <<EOF
apple
banana
cherry
EOF

cat > expected1.txt <<EOF
apple
banana
<added>
cherry
EOF

pied.py '2a <added>' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2a <added>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Append after line matching /ana/
# -------------------------------
cat > input2.txt <<EOF
foo
banana split
bar
EOF

cat > expected2.txt <<EOF
foo
banana split
***append***
bar
EOF

pied.py '/ana/a ***append***' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/ana/a ***append***'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Append after last line ($a)
# -------------------------------
cat > input3.txt <<EOF
line1
line2
EOF

cat > expected3.txt <<EOF
line1
line2
THE END
EOF

pied.py '$a THE END' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '\$a THE END'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Append after every line (global append)
# -------------------------------
cat > input4.txt <<EOF
1
2
3
EOF

cat > expected4.txt <<EOF
1
++
2
++
3
++
EOF

pied.py 'a ++' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: 'a ++'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Append empty line after line 2
# -------------------------------
cat > input5.txt <<EOF
x
y
z
EOF

cat > expected5.txt <<EOF
x
y

z
EOF

pied.py '2a ' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '2a (empty)'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Invalid line number (999a should do nothing)
# -------------------------------
cat > input6.txt <<EOF
m
n
EOF

cat > expected6.txt <<EOF
m
n
EOF

pied.py '999a will-not-insert' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '999a (invalid line)'"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All a-command tests passed."
    exit 0
else
    echo "Some a-command tests failed."
    exit 1
fi
