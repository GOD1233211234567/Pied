#!/usr/bin/env dash

# ==============================================================================
# test00.sh
# Tests for the 'p' command: line number, regex match, $, -n flag, range
# ==============================================================================

PATH="$PATH:$(pwd)"
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

trap 'rm -rf "$test_dir"' INT HUP QUIT TERM EXIT

fail_count=0

# -------------------------------
# Case 1: '2p' should print line 2 twice
# -------------------------------
cat > input1.txt <<EOF
apple
banana
cherry
EOF

cat > expected1.txt <<EOF
apple
banana
banana
cherry
EOF

pied.py '2p' input1.txt > actual1.txt 2>/dev/null

if ! diff expected1.txt actual1.txt >/dev/null 2>&1; then
    echo "Case 1 failed: '2p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 1 passed."
fi

# -------------------------------
# Case 2: '/ana/p' should match 'banana'
# -------------------------------
cat > input2.txt <<EOF
one
banana
three
EOF

cat > expected2.txt <<EOF
one
banana
banana
three
EOF

pied.py '/ana/p' input2.txt > actual2.txt 2>/dev/null

if ! diff expected2.txt actual2.txt >/dev/null 2>&1; then
    echo "Case 2 failed: '/ana/p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 2 passed."
fi

# -------------------------------
# Case 3: '$p' should print last line twice
# -------------------------------
cat > input3.txt <<EOF
x
y
z
EOF

cat > expected3.txt <<EOF
x
y
z
z
EOF

pied.py '$p' input3.txt > actual3.txt 2>/dev/null

if ! diff expected3.txt actual3.txt >/dev/null 2>&1; then
    echo "Case 3 failed: '\$p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 3 passed."
fi



# -------------------------------
# Case 4: '/re/,3p' print from match to line 3
# -------------------------------
cat > input5.txt <<EOF
aa
red here
mid
done
EOF

cat > expected5.txt <<EOF
aa
red here
red here
mid
mid
done
EOF

pied.py '/re/,3p' input5.txt > actual5.txt 2>/dev/null

if ! diff expected5.txt actual5.txt >/dev/null 2>&1; then
    echo "Case 5 failed: '/re/,3p'"
    fail_count=$((fail_count + 1))
else
    echo "Case 5 passed."
fi

# -------------------------------
# Final Result
# -------------------------------
if [ "$fail_count" -eq 0 ]; then
    echo "All p-command tests passed."
    exit 0
else
    echo "Some p-command tests failed."
    exit 1
fi
