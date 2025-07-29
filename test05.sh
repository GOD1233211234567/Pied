#!/usr/bin/env dash

# ==============================================================================
# test05.sh
# Tests for the 'c' (change) command: line number, regex, $, range, global
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
# Case 1: Change line 2
# -------------------------------
cat > input1.txt <<EOF
A
B
C
EOF

cat > expected1.txt <<EOF
A
X
C
EOF

pied.py '2c X' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2c X'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Change line matched by regex /foo/
# -------------------------------
cat > input2.txt <<EOF
abc
foo bar
xyz
EOF

cat > expected2.txt <<EOF
abc
changed
xyz
EOF

pied.py '/foo/c changed' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/foo/c changed'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Change last line ($c)
# -------------------------------
cat > input3.txt <<EOF
one
two
three
EOF

cat > expected3.txt <<EOF
one
two
<last>
EOF

pied.py '$c <last>' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '\$c <last>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Global change (replace every line)
# -------------------------------
cat > input4.txt <<EOF
a
b
c
EOF

cat > expected4.txt <<EOF
repl
repl
repl
EOF

pied.py 'c repl' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: 'c repl'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Change lines in range /begin/,/end/
# -------------------------------
cat > input5.txt <<EOF
keep
begin
in between
end
after
EOF

cat > expected5.txt <<EOF
keep
<block>
after
EOF

pied.py '/begin/,/end/c <block>' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '/begin/,/end/c <block>'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Pattern not found (should not change)
# -------------------------------
cat > input6.txt <<EOF
x
y
z
EOF

cat > expected6.txt <<EOF
x
y
z
EOF

pied.py '/notfound/c oops' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '/notfound/c oops'"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
