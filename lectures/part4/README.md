# Part 4: Programming tools
*chapter 14-15*

* [Makefile](https://www.gnu.org/software/make/manual/make.html)
* [gawk (chapter 14)](https://www.gnu.org/software/gawk/manual/gawk.html)
* [The sed editor(chapter 15)](https://www.gnu.org/software/sed/manual/sed.html)

## The awk pattern processing language

awk is a pattern-scanning and processing language on text files.

* searches one or more files for records (usually lines) that match specified patterns
* processes lines by performing actions each time it finds a match: **pattern { action; }**  No pattern means match every line.
* If a program line does not contain a pattern, gawk selects all lines in the input

awk has many constructs similar to the C programming language

* A flexible format
* Numeric variables
* String variables
* Regular expressions
* Relational expressions
* Conditional execution
* Looping statements
* C's printf
* Coprocess execution (gawk only)
* Network data exchange (gawk only)

awk has many implementations: awk, mawk, nawk, gawk

```bash
# locate awk
ls -l $(which awk)

# usage
gawk --help

# Usage: 
# 1. one-liner: gawk [POSIX or GNU style options] [--] 'program' file 
# gawk fields index from 1
gawk -F: '{ print $1 }' /etc/passwd
# $0 is the whole record
gawk -F: '{ print $0 }' /etc/passwd

# print only lines with more than 9 fields
ls -l /usr/bin | gawk 'NF > 9 {print $0}'

# -----------------------------------------------
#!/bin/bash
# Print a directory report

ls -l /usr/bin | awk '
    BEGIN {
        print "Directory Report"
        print "================================================"
    }
    NF > 9 { # a relational expression
        print $9, "is a symbolic link to", $NF
    }
    END {
        print "============================================="
        print "End Of Report"
    }
'
# -----------------------------------------------
# Program format
BEGIN { # The action's opening brace must be on same line as the pattern

  # Blank lines are ignored

  # Line continuation characters can be used to break long lines
  # there is only one newline right after \
  print \
    $1, # Parameter lists may be broken by commas
    $2, # Comments can appear at the end of any line
    $3

  # Multiple statements can appear on one line if separated by
  # a semicolon
  print "String 1"; print "String 2"

} # Closing brace for action

# 2. program mode: gawk [POSIX or GNU style options] -f progfile [--] filelist
ls -l /usr/bin | awk -f reportprog

```

* Patterns
  * a pattern is a regular expression enclosed within slashes
  ```awk
  $1 ~ /^\(/
  ```
  * relational expressions: both numeric and string comparisons using the relational operators are supported
    ```awk
    NF > 9 
    ```
  * two pattern operators: ~ means match; !~ means not match
  * patterns can be combined using the Boolean operators || (OR) or && (AND)
    ```awk
    $1 > 20 || $NF = "stop"
    ```
  * ! pattern: negate a pattern, only records that do not match the pattern are selected

* Special patterns
  * BEGIN - initialization and configuration, performed before the first record is read; main processing ; END - finalization, performed after the last record is read
  * two patterns separated by a , for a range: begins with the first line that matches the first pattern, ends with the next subsequent line that matches the second pattern
    ```awk
    $2 > 10, ! /middle/
    ```
* Records and fields
  * records are separated by RS, by default RS is a newline
  * fields are separated by FS, by default FS is whitespaces. FS could be a regular expression. The value of FS can be set on the command line like this
  ```bash
    awk -F: '{print $1, "\x27s login shell is ", $7; }' /etc/passwd
  ```

* Actions
  * are taken when there are pattern matches
  * the default action is the print command, it copies the record from the input to standard output
  * multiple items following print will be catenated unless they are separated by commas which tell gawk to separate the items with the output field separator (OFS, normally a SPACE)

* Variables include builtin (program) variables and user variables
  * Unassigned numeric variables are initialized to 0 and string variables to null string
  * the inherent data type in awk is string
  ```awk
  # force awk treat string of digits as a number
  num = 99 + 0
  # force awk treat a number as a string of digits
  str = num "" # by concating it to an empty string
  ```

* gawk builtin variables

| variable | meaning |
| --- | --- |
| FILENAME | Name of the current input file (null for standard input) | 
| FNR | the number of the record read from the file specified on command line |
| $0 | The current record (as a single variable) |
| FS | Input field separator (default: SPACE or TAB ) | 
| \$1-\$n | Fields in the current record | 
| NF | Number of fields in the current record, updates each time a record is read, the last field in the record can be refered by $NF  | 
| NR | Record number of the current record, increments each time a record is read  | 
| OFS | Output field separator (default: SPACE ) | 
| RS | Input record separator (default: NEWLINE) |
| ORS | Output record separator (default: NEWLINE ) | 

* Arrays: gawk support indexed arrays, associate arrays, and multi-dimensional arrays. Under hood, they are all associate arrays.

```awk
# define, delete arrays and their elements
n[1] = 10           # numeric index
s["Mike"] = 99      # string index
matrix[2,3] = 5     # multi-dimensional arrays
delete n[1]         # delete a single element
delete n            # delete array n

# initialize an 1d array
alldays = "Mon,Tue,Wed,Thu,Fri,Sat,Sun"
split(alldays, arrdays, ",")
print arrdays[1] " is before " arrdays[5]

# test whether an element exists
if ( 3 in arrdays) # by testing the index
    print "index 3 exists"

# print all elements
for(i in arrdays)
    print arrdays[i] " is at index " i;


```

## References
* [nawk - pattern-directed scanning and processing language](https://linux.die.net/man/1/nawk)
* [Gawk: Effective AWK Programming](https://www.gnu.org/software/gawk/manual/)
* [handy one-line scripts for awk](https://www.pement.org/awk/awk1line.txt)
* [10 Awk Tips, Tricks and Pitfalls](https://catonmat.net/ten-awk-tips-tricks-and-pitfalls)
* [How to escape a single quote inside awk](https://stackoverflow.com/questions/9899001/how-to-escape-a-single-quote-inside-awk)
* [How to initialize an array of arrays in awk?](https://stackoverflow.com/questions/14063783/how-to-initialize-an-array-of-arrays-in-awk)