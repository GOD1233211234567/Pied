#!/usr/bin/env python3

# Accomplish the basic functionality of sed command.
# Written by: Ziyi Shi
# Date: 2025-04-25
# For COMP2041/9044 Assignment 2

import sys
import re

# =========================================================================
# Class: Line
# Purpose: Represents a single input line with flags and storage for modifications.
#          Supports insert (i), append (a), change (c), 
#           substitute (s), delete (d), and print (p) operations.
# =========================================================================
class Line:
    def __init__(self, line):
        self.content = line
        self.p = False
        self.d = False
        self.inserted_lines = []
        self.appended_lines = []
        self.c_replaced_line = None
        self.s_replaced_line = None

# =========================================================================
# Class: Command
# Purpose: Parses a single command string from the Pied language.
#          Determines command type (a, i, d, p, s, c, q)
#          and stores related parameters like line numbers, regex, and content.
# =========================================================================
class Command:
    def __init__(self, command):
        self.command = command  # The original command string
        self.opt = None  # Command operator
        self.content = None  # "hello"
        self.glb = False  # "s/old/new/g"

        self.start_line_no = None  # Start line number
        self.end_line_no = None  # End line number
        self.start_regrex = None  # Start line regular expression
        self.end_regrex = None  # End line regular expression
        self.pattern = None  # Replacement pattern
        self.replacement = None  # Replacement content

        self.check_q_command()
        self.check_p_command()
        self.check_a_command()
        self.check_i_command()
        self.check_c_command()
        self.check_d_command()
        self.check_s_command()

    # =========================================================================
    # Method: check_q_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize q command syntax and extract relevant data.
    # =========================================================================
    def check_q_command(self):
        m = re.search(r'\s*(\d+)\s*q\s*', self.command)
        if m:
            self.opt = 'q'
            self.start_line_no = int(m.group(1))
            return

        # case: /regex/q
        m = re.match(r'\s*/(.+)/\s*q\s*', self.command)
        if m:
            self.opt = 'q'
            self.start_regrex = m.group(1)  # Save the regex string

    # =========================================================================
    # Method: check_p_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize p command syntax and extract relevant data.
    # =========================================================================
    def check_p_command(self):
        m = re.match(r'\s*/(.+)/\s*,\s*(\d+)\s*p\s*', self.command)
        if m:
            self.opt = 'p'
            self.start_regrex = m.group(1)
            self.end_line_no = int(m.group(2))
            return

        # case: '3p'
        m = re.search(r'\s*(\d+)\s*p\s*', self.command)
        if m:
            self.opt = 'p'
            self.start_line_no = int(m.group(1))
            return

        # case: '/regex/p'
        m = re.match(r'\s*/(.+)/\s*p\s*', self.command)
        if m:
            self.opt = 'p'
            self.start_regrex = m.group(1)
            return

        # case: 'p'
        m = re.match(r'^\s*p\s*$', self.command)
        if m:
            self.opt = 'p'
            self.start_line_no = 0  # represent global
            return

        # case: '$p'
        m = re.match(r'\s*\$\s*p\s*', self.command)
        if m:
            self.opt = 'p'
            self.start_line_no = -2  # Use special value for last line
            return

    # =========================================================================
    # Method: check_a_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize a command syntax and extract relevant data.
    # =========================================================================
    def check_a_command(self):
        m = re.match(r'\s*/(.+)/\s*a\s*(.*)', self.command)
        if m:
            self.opt = 'a'
            self.start_regrex = m.group(1)
            self.content = m.group(2).strip()
            return

        # case: a hello
        m = re.match(r'a\s*(.*)', self.command)
        if m:
            self.opt = 'a'
            self.start_line_no = 0  # Use 0 to represent global
            self.content = m.group(1).strip()

        # case: "3a inserted line"
        m = re.match(r'\s*(\d+)\s*a\s*(.*)', self.command)
        if m:
            self.opt = 'a'
            self.start_line_no = int(m.group(1))
            self.content = m.group(2).strip()

        # case: '$a'
        m = re.match(r'\s*\$\s*a\s*(.*)', self.command)
        if m:
            self.opt = 'a'
            self.start_line_no = -2  # Use special value for last line
            self.content = m.group(1).strip()
            return

    # =========================================================================
    # Method: check_i_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize i command syntax and extract relevant data.
    # =========================================================================
    def check_i_command(self):
        m = re.match(r'\s*/(.+)/\s*i\s*(.*)', self.command)
        if m:
            self.opt = 'i'
            self.start_regrex = m.group(1)
            self.content = m.group(2).strip()
            return

        # case: '$i'
        m = re.match(r'\s*\$\s*i\s*(.*)', self.command)
        if m:
            self.opt = 'i'
            self.start_line_no = -2  # Use special value for last line
            self.content = m.group(1).strip()
            return

        # case: "3i inserted line"
        m = re.match(r'\s*(\d+)\s*i\s*(.*)', self.command)
        if m:
            self.opt = 'i'
            self.start_line_no = int(m.group(1))
            self.content = m.group(2).strip()

        # case: i hello
        m = re.match(r'^\s*i\s*(.*)', self.command)
        if m:
            self.opt = 'i'
            self.start_line_no = 0  # 0 means global insert
            self.content = m.group(1).strip()
            return

    # =========================================================================
    # Method: check_c_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize c command syntax and extract relevant data.
    # =========================================================================
    def check_c_command(self):
        m = re.match(r'\s*/(.+)/\s*,\s*/(.+)/\s*c\s*(.*)', self.command)
        if m:
            self.opt = 'c'
            self.start_regrex = m.group(1)
            self.end_regrex = m.group(2)
            self.content = m.group(3).strip()
            return

        # case: /regex/c content
        m = re.match(r'\s*/(.+)/\s*c\s*(.*)', self.command)
        if m:
            self.opt = 'c'
            self.start_regrex = m.group(1)
            self.content = m.group(2).strip()
            return

        # case: "2c replacement"
        m = re.match(r'\s*(\d+)\s*c\s*(.*)', self.command)
        if m:
            self.opt = 'c'
            self.start_line_no = int(m.group(1))
            self.content = m.group(2).strip()

    # =========================================================================
    # Method: check_d_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize d command syntax and extract relevant data.
    # =========================================================================
    def check_d_command(self):
        m = re.match(r'\s*(\d+)\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_line_no = int(m.group(1))

        # case: "/pattern/d"
        m = re.match(r'\s*/(.+)/\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_regrex = m.group(1)

        # case: "d"
        m = re.match(r'^\s*d\s*$', self.command)
        if m:
            self.opt = 'd'
            self.start_line_no = 0  # Use 0 for global

        # case: '$d'
        m = re.match(r'\s*\$\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_line_no = -2

        # case: 2,3d
        m = re.match(r'\s*(\d+)\s*,\s*(\d+)\s*d\s*$', self.command)
        if m:
            self.opt = 'd'
            self.start_line_no = int(m.group(1))
            self.end_line_no = int(m.group(2))
            return

        # case: 3,/2/d
        m = re.match(r'\s*(\d+)\s*,\s*/(.+)/\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_line_no = int(m.group(1))
            self.end_regrex = m.group(2)
            return

        # /2/,7d
        m = re.match(r'\s*/(.+)/\s*,\s*(\d+)\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_regrex = m.group(1)
            self.end_line_no = int(m.group(2))
            return

        # /2/,/7/d
        m = re.match(r'\s*/(.+)/\s*,\s*/(.+)/\s*d\s*', self.command)
        if m:
            self.opt = 'd'
            self.start_regrex = m.group(1)
            self.end_regrex = m.group(2)
            return

    # =========================================================================
    # Method: check_s_command
    # Input: self.command (string format command)
    # Output: Sets the command type and parameters if matched.
    # Purpose: Recognize s command syntax and extract relevant data.
    # =========================================================================
    def check_s_command(self):
        m = re.match(r'\s*s(.)(.*?)(\1)(.*?)(\1)(g?)\s*$', self.command)
        if m:
            self.opt = 's'
            self.start_line_no = 0
            self.pattern = m.group(2)
            self.replacement = m.group(4)
            self.glb = (m.group(6) == 'g')
            return

        # Line number + substitution or line number + substitution + global
        m = re.match(r'\s*(\d+)\s*s/([^/]+)/([^/]*)/(g?)\s*$', self.command)
        if m:
            self.opt = 's'
            self.start_line_no = int(m.group(1))
            self.pattern = m.group(2)
            self.replacement = m.group(3)
            self.glb = (m.group(4) == 'g')
            return

        # /start/,/end/s/pattern/replacement/[g]
        m = re.match(r'\s*/(.+)/\s*,\s*/(.+)/\s*s/([^/]+)/([^/]*)/(g?)\s*$', self.command)
        if m:
            self.opt = 's'
            self.start_regrex = m.group(1)
            self.end_regrex = m.group(2)
            self.pattern = m.group(3)
            self.replacement = m.group(4)
            self.glb = (m.group(5) == 'g')
            return

        # Single regex + substitution or single regex + substitution + g
        m = re.match(r'\s*/(.+)/\s*s/([^/]+)/([^/]*)/(g?)\s*$', self.command)

        if m:
            self.opt = 's'
            self.start_regrex = m.group(1)
            self.pattern = m.group(2)
            self.replacement = m.group(3)
            self.glb = (m.group(4) == 'g')
            return

        # Global substitution or global substitution + g
        m = re.match(r'\s*s/([^/]+)/([^/]*)/(g?)\s*$', self.command)

        if m:
            self.opt = 's'
            self.start_line_no = 0
            self.pattern = m.group(1)
            self.replacement = m.group(2)
            self.glb = (m.group(3) == 'g')
            return

        # '$s/pat/repl/'
        m = re.match(r'\s*\$\s*s/([^/]+)/([^/]*)/(g?)\s*$', self.command)

        if m:
            self.opt = 's'
            self.start_line_no = -2
            self.pattern = m.group(1)
            self.replacement = m.group(2)
            self.glb = (m.group(3) == 'g')
            return


#
# Class: Pied
# Purpose: Simulates a sed-like stream editor.
#          Reads text lines from file or stdin, applies parsed Pied commands, and prints results.
#
class Pied:

    # =========================================================================
    # Method: __init__
    # Input: command_args (string), txt_files (list of input file names), pied_file (command file or None)
    # Output: Initializes class state and parses command arguments.
    # Purpose: Prepares Pied command list and input file tracking.
    # =========================================================================
    def __init__(self, command_args, txt_files, pied_file):

        self.n_flag = False
        self.command_args = command_args
        self.txt_files = txt_files
        self.pied_file = pied_file

        if command_args.startswith("-n "):
            self.n_flag = True
            command_args = command_args[3:].strip()

        self.read_stop = -1
        self.commands = []
        self.input_lines = []
        self.output_lines = []

        command_lines = []
        for cmd in command_args.split(";"):
            stripped_cmd = cmd.strip()
            if stripped_cmd:
                command_lines.append(stripped_cmd)

        for argument in command_lines:
            command = Command(argument)
            if command.opt == 'q':
                if self.read_stop == -1 or command.start_line_no < self.read_stop:
                    self.read_stop = command.start_line_no
            self.commands.append(command)

    # =========================================================================
    # Method: stop_reading
    # Input: current_line (string), current_nr (int)
    # Output: Returns True if a 'q' command indicates to stop reading.
    # Purpose: Check if line should halt input based on a quit condition.
    # =========================================================================
    def stop_reading(self, current_line, current_nr):

        for idx, command in enumerate(self.commands):

            # Case 1: 'q' command associated with a regular expression
            if command.opt == 'q' and command.start_regrex is not None:

                # If there is only one command, or this is the first command
                if len(self.commands) == 1 or idx == 0:

                    # If the current line matches the regular expression, stop reading
                    if re.search(command.start_regrex, current_line):
                        return True

            # Case 2: 'q' command associated with a specific line number
            elif command.opt == 'q' and command.start_line_no is not None:

                # If the current line number matches the target line number
                if current_nr == command.start_line_no:

                    # Assume the current line was not deleted by any previous 'd' (delete) command
                    deleted_by_prev_d = False

                    # Check all commands before this 'q' command
                    for prev in self.commands[:idx]:

                        # Only consider previous 'd' (delete) commands
                        if prev.opt != 'd':
                            continue

                        # If the previous 'd' command matches this line by line number or regex
                        if (
                            # 'd' command on a specific single line
                            prev.start_regrex is None
                            and prev.end_regrex is None
                            and prev.end_line_no is None
                            and prev.start_line_no == current_nr
                        ) or (
                            # 'd' command on a line range
                            prev.start_line_no is not None
                            and prev.end_line_no is not None
                            and prev.start_line_no <= current_nr <= prev.end_line_no
                        ) or (
                            # 'd' command matches line content via regular expression
                            prev.start_regrex and re.search(prev.start_regrex, current_line)
                        ):
                            # The current line would have been deleted by a previous 'd' command
                            deleted_by_prev_d = True
                            break  # No need to check further once matched

                    # If the current line is not deleted by any prior 'd' command, stop reading
                    if not deleted_by_prev_d:
                        return True

        # If no conditions matched, continue reading
        return False

    # =========================================================================
    # Method: read_lines
    # Input: stop (optional int for max line count to read)
    # Output: Populates self.input_lines from stdin or txt_files.
    # Purpose: Load input lines for later processing.
    # =========================================================================
    def read_lines(self, stop=-1):

        if self.txt_files:
            for fname in self.txt_files:
                try:
                    with open(fname) as f:
                        for raw_line in f:
                            line = raw_line.rstrip('\n')
                            self.input_lines.append(Line(line))
                            current_nr = len(self.input_lines)
                            if self.stop_reading(line, current_nr):
                                return
                except FileNotFoundError:
                    print(f"Error: Input file '{fname}' not found.", file=sys.stderr)
                    sys.exit(1)
        else:
            while True:
                try:
                    line = input()
                    self.input_lines.append(Line(line))
                    current_nr = len(self.input_lines)
                    if self.stop_reading(line, current_nr):
                        return
                except EOFError:
                    break


    # =========================================================================
    # Method: display
    # Input: None
    # Output: Prints processed lines according to all applied commands.
    # Purpose: Render the final text output after transformations.
    # =========================================================================
    def display(self):

        for line in self.input_lines:
            # Skip deleted lines directly (d command has the highest priority)
            if line.d:
                continue

            # If -n is enabled, only print lines marked with p
            if self.n_flag:
                if line.p:
                    if line.c_replaced_line is not None:
                        print(line.c_replaced_line)
                    elif line.s_replaced_line is not None:
                        print(line.s_replaced_line)
                    else:
                        print(line.content)
                continue  # In -n mode, do not output other lines

            # Insert command content (i): insert before current line
            for inserted in line.inserted_lines:
                print(inserted)

            # Replace command c has the highest priority
            if line.c_replaced_line is not None:
                print(line.c_replaced_line)
                # Print appended command (a): append after current line
                for appended in line.appended_lines:
                    print(appended)
                continue  # Do not process s or p further

            # Handle the combination logic of s and p
            if line.p:
                if line.s_replaced_line is None:
                    print(line.content)
                    print(line.content)
                else:
                    print(line.content)
                    print(line.s_replaced_line)
            else:
                if line.s_replaced_line is None:
                    print(line.content)
                else:
                    print(line.s_replaced_line)

            # Print appended command content (a)
            for appended in line.appended_lines:
                print(appended)

    # =========================================================================
    # Method: process_p_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the p command to target lines.
    # =========================================================================
    def process_p_command(self, command):

        # Case 1: 'p' command with a specific line number
        if command.start_line_no is not None:

            if command.start_line_no == 0:
                # '0p' => mark all lines to be printed
                for line in self.input_lines:
                    line.p = True
            else:
                # Convert to 0-based index
                index = command.start_line_no - 1

                # Check if index is out of range; if so, do nothing
                if index < 0 and command.start_line_no != -2 or index >= len(self.input_lines):
                    return

                # Special case: -2 means last line
                if command.start_line_no != -2:
                    line = self.input_lines[index]
                else:
                    line = self.input_lines[-1]

                # Mark the selected line to be printed
                if command.opt == 'p':
                    line.p = True

        # Case 2: 'p' command with a starting regular expression
        elif command.start_regrex is not None:

            # Case 2a: /pattern/,5p => from first match up to line 5
            if command.end_line_no is not None:
                start = 0
                while start < len(self.input_lines):
                    # Find the next line matching the start regex
                    while start < len(self.input_lines):
                        line = self.input_lines[start]
                        if not line.p and re.search(command.start_regrex, line.content):
                            break
                        start += 1
                    else:
                        break  # No more matches found

                    # Determine end line index
                    end = command.end_line_no - 1

                    if end < start or end >= len(self.input_lines):
                        # If end line invalid, only mark the matching line
                        self.input_lines[start].p = True
                        start += 1
                    else:
                        # Otherwise, mark lines from start to end
                        for i in range(start, end + 1):
                            self.input_lines[i].p = True
                        start = end + 1

            # Case 2b: /pattern/p => match single lines individually
            else:
                for line in self.input_lines:
                    if not line.d and re.search(command.start_regrex, line.content):
                        line.p = True

    # =========================================================================
    # Method: process_d_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the d command to target lines.
    # =========================================================================
    def process_d_command(self, command):

        if command.start_line_no is not None:
            if command.start_line_no == 0:
                    for line in self.input_lines:
                        line.d = True
            elif command.end_line_no is not None:
                start = command.start_line_no - 1
                end = command.end_line_no
                for i in range(start, end):
                    if 0 <= i < len(self.input_lines):
                        self.input_lines[i].d = True
            # 3,/pattern/d
            elif command.end_regrex is not None:
                while True:
                    # Start at the specified line number
                    start_index = command.start_line_no - 1
                    if start_index < 0 or start_index >= len(self.input_lines):
                        break

                    # Find the first line after start_index matching end_regrex
                    end_index = -1
                    for i in range(start_index + 1, len(self.input_lines)):
                        if not self.input_lines[i].d and re.search(command.end_regrex, self.input_lines[i].content):
                            end_index = i
                            break

                    # If no end found, delete to the end
                    if end_index == -1:
                        end_index = len(self.input_lines) - 1

                    # Mark all lines from start to end_index as deleted
                    for i in range(start_index, end_index + 1):
                        self.input_lines[i].d = True

                    break

            else:
                index = command.start_line_no - 1
                if index < 0 and command.start_line_no != -2 or index >= len(self.input_lines):
                    return

                if command.start_line_no != -2:
                    line = self.input_lines[index]
                else:
                    line = self.input_lines[-1]

                if command.opt == 'd':
                    line.d = True

        elif command.start_regrex is not None:
            # /pattern/,7d
            if command.end_line_no is not None:

                start = 0
                while start < len(self.input_lines):
                    # Find the next line matching the start pattern
                    while start < len(self.input_lines):
                        line = self.input_lines[start]
                        if not line.d and re.search(command.start_regrex, line.content):
                            break
                        start += 1
                    else:
                        break

                    end = command.end_line_no - 1

                    if end < start or end >= len(self.input_lines):
                        # If the end is before the start or out of range, only mark the start
                        self.input_lines[start].d = True
                        start += 1
                    else:
                        # Valid range, mark all as deleted
                        for i in range(start, end + 1):
                            self.input_lines[i].d = True
                        start = end + 1

            elif command.end_regrex is not None:
                # /pattern1/,/pattern2/d
                while True:
                    # Find the first line matching start_regrex and not deleted
                    start_index = -1
                    for i, line in enumerate(self.input_lines):
                        if not line.d and re.search(command.start_regrex, line.content):
                            start_index = i
                            break

                    if start_index == -1:
                        break

                    # From start_index, find the first line matching end_regrex
                    end_index = -1
                    for i in range(start_index + 1, len(self.input_lines)):
                        if not self.input_lines[i].d and re.search(command.end_regrex,
                                                                   self.input_lines[i].content):
                            end_index = i
                            break

                    if end_index == -1:
                        for i in range(start_index, len(self.input_lines)):
                            self.input_lines[i].d = True
                        break

                    # Mark lines from start to end_index (inclusive) as deleted
                    for i in range(start_index, end_index + 1):
                        self.input_lines[i].d = True
            else:
                # /pattern/d
                for line in self.input_lines:
                    if re.search(command.start_regrex, line.content):
                        line.d = True
        elif command.start_line_no == -2:
            if self.input_lines:
                self.input_lines[-1].d = True

    # =========================================================================
    # Method: process_s_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the s command to target lines.
    # =========================================================================
    def process_s_command(self, command):

        # /start/,/end/s/pattern/replacement/[g]
        if command.start_regrex is not None and command.end_regrex is not None:
            start = 0
            while start < len(self.input_lines):
                # find the next line matching start_regrex
                while start < len(self.input_lines):
                    line = self.input_lines[start]
                    if not line.d and re.search(command.start_regrex, line.content):
                        break
                    start += 1
                else:
                    break

                # find the next line matching end_regrex
                end = start
                while end < len(self.input_lines):
                    if not self.input_lines[end].d and re.search(command.end_regrex, self.input_lines[end].content):
                        break
                    end += 1
                else:
                    break

                # apply substitution within the range
                for i in range(start, end + 1):
                    line = self.input_lines[i]
                    try:
                        if command.glb:
                            line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content)
                        else:
                            line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content, count=1)
                    except re.error:
                        pass

                start = end + 1  # move to next range

        # /regex/s/pattern/replacement/[g]
        elif command.start_regrex is not None:
            for line in self.input_lines:
                if re.search(command.start_regrex, line.content):
                    if command.glb:
                        try:
                            line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content)
                        except re.error:
                            pass
                    else:
                        try:
                            line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content, count=1)
                        except re.error:
                            pass
        # s/pattern/replacement/[g]
        elif command.start_line_no == 0:
            for line in self.input_lines:
                if command.glb:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content)
                    except re.error:
                        pass
                else:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content, count=1)
                    except re.error:
                        pass
        # $s/pattern/replacement/[g]
        elif command.start_line_no == -2:
            if self.input_lines:
                line = self.input_lines[-1]
                if command.glb:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content)
                    except re.error:
                        pass
                else:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content, count=1)
                    except re.error:
                        pass
        # N s/pattern/replacement/[g]
        else:
            index = command.start_line_no - 1
            if 0 <= index < len(self.input_lines):
                line = self.input_lines[index]
                if command.glb:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content)
                    except re.error:
                        pass
                else:
                    try:
                        line.s_replaced_line = re.sub(command.pattern, command.replacement, line.content, count=1)
                    except re.error:
                        pass

    # =========================================================================
    # Method: process_c_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the c command to target lines.
    # =========================================================================
    def process_c_command(self, command):
        if command.start_line_no is not None:
            index = command.start_line_no - 1

            if index < 0 and command.start_line_no != -2 or index >= len(self.input_lines):
                return

            if command.start_line_no != -2:
                line = self.input_lines[index]
            else:
                line = self.input_lines[-1]


            if command.opt == 'c':
                line.c_replaced_line = command.content

        elif command.start_regrex is not None and command.end_regrex is not None:

            start = 0
            while start < len(self.input_lines):
                # Find the next line matching the start pattern
                while start < len(self.input_lines):
                    line = self.input_lines[start]
                    if not line.d and re.search(command.start_regrex, line.content):
                        break
                    start += 1
                else:
                    break

                # Find the end line
                end = start + 1
                while end < len(self.input_lines):
                    if not self.input_lines[end].d and re.search(command.end_regrex, self.input_lines[end].content):
                        break
                    end += 1
                else:
                    break

                # Replace all lines in the range
                for i in range(start, end + 1):
                    if i == start:
                        self.input_lines[i].c_replaced_line = command.content
                    else:
                        self.input_lines[i].d = True

                start = end + 1  # Update for next start
        elif command.start_regrex is not None:
            for line in self.input_lines:
                if not line.d and re.search(command.start_regrex, line.content):
                    line.c_replaced_line = command.content
        elif command.start_line_no == 0:
            for line in self.input_lines:
                line.c_replaced_line = command.content
        elif command.start_line_no == -2:
            if self.input_lines:
                self.input_lines[-1].c_replaced_line = command.content

    # =========================================================================
    # Method: process_a_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the a command to target lines.
    # =========================================================================
    def process_a_command(self, command):

        if command.start_line_no == 0:
            for line in self.input_lines:
                line.appended_lines.append(command.content)
        elif command.start_regrex is not None:
            for line in self.input_lines:
                if re.search(command.start_regrex, line.content):
                    line.appended_lines.append(command.content)
        elif command.start_line_no == -2:
            if self.input_lines:
                self.input_lines[-1].appended_lines.append(command.content)
        else:
            index = command.start_line_no - 1
            if index < 0 and command.start_line_no != -2 or index >= len(self.input_lines):
                return
            line = self.input_lines[index]
            line.appended_lines.append(command.content)



    # =========================================================================
    # Method: process_i_command
    # Input: Command object (containing parsed type and arguments)
    # Output: Modifies Line object state accordingly.
    # Purpose: Apply the i command to target lines.
    # =========================================================================
    def process_i_command(self, command):
        if command.start_line_no == 0:
            for line in self.input_lines:
                line.inserted_lines.append(command.content)
        elif command.start_regrex is not None:
            for line in self.input_lines:
                if re.search(command.start_regrex, line.content):
                    line.inserted_lines.append(command.content)
        elif command.start_line_no == -2:
            if self.input_lines:
                self.input_lines[-1].inserted_lines.append(command.content)
        else:
            index = command.start_line_no - 1
            if index < 0 and command.start_line_no != -2 or index >= len(self.input_lines):
                return
            line = self.input_lines[index]
            line.inserted_lines.append(command.content)

    # =========================================================================
    # Method: analyse
    # Input: None
    # Output: Executes all parsed commands and displays final output.
    # Purpose: Entry point for running the editor logic.
    # =========================================================================
    def analyse(self):

        self.read_lines(self.read_stop)
        for command in self.commands:
            if command.opt == 'p':
                self.process_p_command(command)

            if command.opt == 'd':
                self.process_d_command(command)

            if command.opt == 's':
                self.process_s_command(command)

            if command.opt == 'c':
                self.process_c_command(command)

            if command.opt == 'a':
                self.process_a_command(command)
                continue
            if command.opt == 'i':
                self.process_i_command(command)
                continue

        self.display()



if __name__ == "__main__":
    # Get command-line arguments, excluding the script name
    raw_args = sys.argv[1:]

    command_args = None
    txt_files = []
    pied_file = None

    # Check if commands should be loaded from a command file
    if "-f" in raw_args:
        f_index = raw_args.index("-f")
        if f_index + 1 < len(raw_args):
            pied_file = raw_args[f_index + 1]
            txt_files = raw_args[f_index + 2:]
            try:
                with open(pied_file) as f:
                    commands = []
                    for line in f:
                        line = line.strip()
                        if line.startswith("#") or line.startswith(":"):
                            continue
                        if line:
                            commands.extend([cmd.strip() for cmd in line.split(";") if cmd.strip()])
                    command_args = ";".join(commands)
                    command_args = command_args.replace("\\", "")
            except FileNotFoundError:
                print(f"Error: Command file '{pied_file}' not found.", file=sys.stderr)
                sys.exit(1)
        else:
            print("Error: -f option requires a filename", file=sys.stderr)
            sys.exit(1)
    # Otherwise, treat arguments as inline commands and input files
    else:
        txt_files = [arg for arg in raw_args if arg.endswith('.txt')]
        command_args = " ".join([arg for arg in raw_args if arg not in txt_files])
        command_args = command_args.replace("\\", "")

    # Create Pied instance and start processing
    pied = Pied(command_args, txt_files, pied_file)
    pied.analyse()