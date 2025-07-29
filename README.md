# Pied - A Stream Editor Implementation

## Overview

Pied is a Python implementation of a stream editor, similar to the Unix `sed` command. It provides a powerful text processing tool that can perform various operations on text files including printing, deleting, substituting, inserting, appending, and changing lines based on line numbers or regular expressions.

**Author:** Ziyi Shi  
**Date:** 2025-09

## Features

Pied supports the following commands:

- **p** - Print lines
- **d** - Delete lines  
- **s** - Substitute/replace text
- **a** - Append text after lines
- **i** - Insert text before lines
- **c** - Change/replace entire lines
- **q** - Quit processing

## Installation

1. Ensure you have Python 3 installed on your system
2. Download the `pied.py` file
3. Make the script executable (optional):
   ```bash
   chmod +x pied.py
   ```

## Usage

### Basic Syntax

```bash
python3 pied.py [commands] [input_files]
```

### Command Line Options

- **-f filename**: Read commands from a file instead of command line arguments

### Examples

#### 1. Print specific lines

```bash
# Print line 2
python3 pied.py '2p' input.txt

# Print lines matching a pattern
python3 pied.py '/pattern/p' input.txt

# Print the last line
python3 pied.py '$p' input.txt
```

#### 2. Delete lines

```bash
# Delete line 3
python3 pied.py '3d' input.txt

# Delete lines matching a pattern
python3 pied.py '/pattern/d' input.txt
```

#### 3. Substitute text

```bash
# Replace first occurrence of 'old' with 'new'
python3 pied.py 's/old/new/' input.txt

# Replace all occurrences (global)
python3 pied.py 's/old/new/g' input.txt

# Replace in specific line range
python3 pied.py '1,3s/old/new/' input.txt
```

#### 4. Insert and append text

```bash
# Insert text before line 2
python3 pied.py '2i\new line' input.txt

# Append text after line 2
python3 pied.py '2a\new line' input.txt

# Insert before lines matching pattern
python3 pied.py '/pattern/i\new line' input.txt
```

#### 5. Change entire lines

```bash
# Replace line 2 with new content
python3 pied.py '2c\new content' input.txt

# Replace lines matching pattern
python3 pied.py '/pattern/c\new content' input.txt
```

#### 6. Using command files

Create a file with commands:
```
$q
/2/d
```

Then run:
```bash
python3 pied.py -f commands.txt input.txt
```

## Command Syntax

### Line Addressing

- **Number**: `3p` - Line 3
- **$**: `$p` - Last line
- **Range**: `1,3p` - Lines 1 to 3
- **Regex**: `/pattern/p` - Lines matching pattern
- **Regex range**: `/start/,/end/p` - From first match of 'start' to first match of 'end'

### Command Types

| Command | Description | Example |
|---------|-------------|---------|
| `p` | Print lines | `2p`, `/pattern/p` |
| `d` | Delete lines | `3d`, `/pattern/d` |
| `s/old/new/[g]` | Substitute text | `s/old/new/g` |
| `a\text` | Append text | `2a\new line` |
| `i\text` | Insert text | `2i\new line` |
| `c\text` | Change lines | `2c\new content` |
| `q` | Quit | `5q` |

## Testing

The project includes comprehensive test suites (`test00.sh` through `test09.sh`) that verify the functionality of all commands and edge cases.

To run tests:
```bash
# Make test scripts executable
chmod +x test*.sh

# Run individual tests
./test00.sh
./test01.sh
# ... etc
```

## File Structure

```
ass2/
├── pied.py              # Main implementation
├── test00.sh - test09.sh # Test suites
├── commandsFile          # Example command file
├── commandsFilenseq      # Example command file
├── test.txt             # Sample input file
└── README.md            # This file
```

## Implementation Details

The implementation consists of three main classes:

1. **Line**: Represents a single input line with modification flags
2. **Command**: Parses and stores command parameters
3. **Pied**: Main editor class that processes commands and manages the editing workflow

### Key Features

- **Regular Expression Support**: Full regex matching for line addressing
- **Multiple Input Files**: Process multiple files in sequence
- **Command Files**: Load commands from external files
- **Error Handling**: Robust error handling for invalid commands and file operations
- **Flexible Addressing**: Support for line numbers, ranges, and regex patterns

## Error Handling

The program handles various error conditions:

- Invalid command syntax
- File not found errors
- Invalid line numbers
- Malformed regular expressions

Error messages are printed to stderr, while processed output goes to stdout.

## Limitations

- Limited to text file processing
- No in-place editing (output is always to stdout)
- Basic regex support (no extended regex features)
