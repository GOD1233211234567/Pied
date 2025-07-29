#!/usr/bin/env dash

# ==============================================================================
# test02.sh
# Tests for the 's' command: basic, global, line-specific, regex, $, ranges
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
# Case 1: Basic substitution (first only)
# -------------------------------
cat > input1.txt <<EOF
I like dogs.
I like cats.
EOF

cat > expected1.txt <<EOF
I love dogs.
I like cats.
EOF

pied.py 's/like/love/' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: 's/like/love/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: Global substitution
# -------------------------------
cat > input2.txt <<EOF
red red red
EOF

cat > expected2.txt <<EOF
blue blue blue
EOF

pied.py 's/red/blue/g' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: 's/red/blue/g'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: Substitute only line 3
# -------------------------------
cat > input3.txt <<EOF
line1
line2
like this one
line4
EOF

cat > expected3.txt <<EOF
line1
line2
love this one
line4
EOF

pied.py '3s/like/love/' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '3s/like/love/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi

# -------------------------------
# Case 4: Substitute lines matching regex
# -------------------------------
cat > input4.txt <<EOF
ignore me
target: apple pie
ignore this
EOF

cat > expected4.txt <<EOF
ignore me
target: banana pie
ignore this
EOF

pied.py '/apple/s/apple/banana/' input4.txt > actual4.txt 2>/dev/null

if ! diff expected4.txt actual4.txt >/dev/null 2>&1; then
    echo "Case 4 failed: '/apple/s/apple/banana/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 4 passed."
fi

# -------------------------------
# Case 5: Substitute last line only
# -------------------------------
cat > input5.txt <<EOF
one
two
final stage
EOF

cat > expected5.txt <<EOF
one
two
final phase
EOF

pied.py '$s/stage/phase/' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '\$s/stage/phase/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Case 6: Range substitution
# -------------------------------
cat > input6.txt <<EOF
skip
start here
hello
end here
final
EOF

cat > expected6.txt <<EOF
skip
start here
hi
end here
final
EOF

pied.py '/start/,/end/s/hello/hi/' input6.txt > actual6.txt 2>/dev/null

if ! diff expected6.txt actual6.txt >/dev/null 2>&1; then
    echo "Case 6 failed: '/start/,/end/s/hello/hi/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 6 passed."
fi

# -------------------------------
# Case 7: Pattern not found (no substitution)
# -------------------------------
cat > input7.txt <<EOF
hello world
foo bar
EOF

cat > expected7.txt <<EOF
hello world
foo bar
EOF

pied.py 's/xyz/123/' input7.txt > actual7.txt 2>/dev/null

if ! diff expected7.txt actual7.txt >/dev/null 2>&1; then
    echo "Case 7 failed: 's/xyz/123/'"
    fail_count=$((fail_count + 1))
else
    echo "Case 7 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All s-command tests passed."
    exit 0
else
    echo "Some s-command tests failed."
    exit 1
fi
