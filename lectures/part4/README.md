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

# initialize a 1d array
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

* Arithmetic and Logical Expressions
  * AWK arithmetic is **floating point**
  * Arithmetic and logical expressions can be used in both patterns and actions

| Group      | operators  |
| ---------- | ---------- |
| Arithmetic |	+, -, *, /, %, ^  |
| Assignment |	=, +=, -=, *=, /=, %=, ^=, ++, --  |
| Relational |	<, >, <=, >=, ==, !=  |
| Matching	 |  \~, !\~  |
| Logical	 |    \|\|, &&  |
| Array	     |  in |

```awk
# 1. counts the number of lines containing exactly 9 fields
ls -l /usr/bin | awk 'NF == 9 {count++} END {print count}'

# 2. calculates the total size of the files in the list
ls -l /usr/bin | awk 'NF >=9 {total += $5} END {print total}'

# 3. calculates the average size of the files
ls -l /usr/bin | awk 'NF >=9 {c++; t += $5} END {print t / c}'

```

* Flow controls
  * Sequence: {a = a + 1; b = b * a}
  * Branch: if/then/else 
  ```awk
  ls -l /usr/bin | awk '
  BEGIN {
      page_length = 60
  }
  {
      if (NR % page_length)
          print
      else
          print "\f" $0
  }
  '
  ```
  * array membership test: var, var1, var2 are index values
    * 1d array: (var in array)
    * 2d array: ((var1,var2) in array)
  * Repetition:
    * C-style for loop
    ```awk
    ls -l | awk '{s = ""; for (i = NF; i > 0; i--) s = s $i OFS; print s}'
    ```
    * for ( var in array ) : :warning: *that the order of the elements in memory is implementation dependent*
    ```awk
    awk 'BEGIN {for (i=0; i<10; i++) a[i]="foo"; for (i in a) print i}'
    ```
    * while ( condition ) and do statement while ( condition )
    ```awk
    # reverse fields order
      ls -l | awk '{
      s = ""
      i = NF
      while (i > 0) {
          s = s $i OFS
          i--
      }
      print s
    }'
    ```
    * loop alteration: continue/break/next/exit
      * continue stops the current iteration and continues with the next iteration
      * break exits the current loop entirely
      * next skips the remainder of the current program and begins processing the next record of input
      * exit expression is similar to bash

* Regular expressions
  * Similar to those in egrep
  * often used in patterns

```awk
# count the number of files of different types under /usr/bin
ls -l /usr/bin | awk '
$1 ~ /^-/ {t["Regular files"]++}
$1 ~ /^d/ {t["Directories"]++}
$1 ~ /^l/ {t["Symbolic links"]++}
END {for (i in t) print i ":\t" t[i]}
'
```

* Input
  * getline: reads the next record from the current input stream and sets $0, NF, NR, and FNR 
  * getline var: reads the next record from the current input stream and assigns its contents to the variable var.  NR and FNR are also set
  * getline <file: reads a record from file and sets $0, NF
  * getline var <file: reads the next record from file and assigns its contents to the variable var
  * command | getline: reads the next record from the output of command and set $0, NF
  * command | getline var: reads the next record from the output of command and assigns its contents to the variable var

```awk
# 1. read from files to simulate the cat command
awk '{print $0}' file1 file2 file3

# 2. count characters, words and lines in a file
# length does not count newlines, the NR in chars+NR counts them
awk '{chars += length($0); words += NF}
    END {print NR, words, chars + NR}' file1 

# 3. using getline
awk '
    BEGIN {
        while (getline <"header.txt" > 0) { # >0 means successful read
            print $0
        }
    }
    {print}
    END {
        while (getline <"footer.txt" > 0) {
            print $0
        }
    } 
' < body.txt > finished_file.txt

```


* Output
  * print expr1, expr2, expr3, …
    * The commas tell AWK to separate output items with the output field separator (OFS)
    * Otherwise, expr1 expr2 expr3 are concatenated into a single string
  * printf(format, expr1, expr2, expr3, …)
  * write to files using redirection and pipelines

```awk
# 1. formatted output
ls -l /usr/bin | awk '{printf("%-30s%8.2fK\n", $9, $5 / 1024)}'

# 2. redirection
ls -l /usr/bin | awk '
$1 ~ /^-/ {print $0 > "regfiles.txt"}
$1 ~ /^d/ {print $0 > "directories.txt"}
$1 ~ /^l/ {print $0 > "symlinks.txt"}
'

# 3. to pipeline
ls -l /usr/bin | awk '
$1 ~ /^-/ {a[$9] = $5}
END {for (i in a)
    {print a[i] "\t" i | "sort -nr"}
}
'

# 4. convert a file into csv format
gawk 'BEGIN {OFS=","} {print $1,$2,$3,$4,$5,$6}' data.dat

# gawk can't read embedded comma graciously like field1, "field2a, field2b", field3

# 5. convert a file into tsv format
awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5}' data.dat

```

* Functions
  * gawk has many builtin string functions and arithmetic functions

*Note: string index startsfrom 1*

| string functions | usage and parameters | return |
| ---- | ---- | ---- |
| length(s) |  | the number of characters in string s |
| index(s1, s2) |  | the leftmost position of string s2 within string s1; 0 if s2 not found in s1 |
| substr(s, p, l) |  | the substring contained within string s starting at position p with length l |
| match(s, r) |  | the leftmost position of a substring matching regular expression r within string s; 0 if no match is found. This function also sets the internal variables RSTART and RLENGTH |
| gsub(r, s, t) | Globally replaces all substring matching regular expression r contained within target string t with string s, the default value of t is $0 | the number of substitutions made |
| sub(r, s, t) | like gsub, replaces only the first leftmost match, the default value of t is $0 |  |
| split(s, a, fs) | splits string s into fields according to field separator fs and stores each field in an element of array a |
| sprintf(fmt, exprs) | like C sprintf | a formatted string containing the list of exprs |

* arithmetic functions are similar to their C counterparts: 
  * sin(x), cos(x), atan2(y,x) - the arctangent of y/x in radians
  * rand(), srand(x)
  * sqrt(x), log(x), exp(x), int(x) - the integer portion of x

* gawk supports user-defined functions like bash, but passes parameters like C
  * scalar parameters are passed by value
  * **array parameters are passed by reference**
  * **gawk does not support declaring local variables within the body of a function**. A walkaround is adding scalar variables to the parameter list since AWK does not enforce the parameter list.
  ```gawk
  function my_funct(param1, param2, param3, ..., paramn,    local1, local2, ..., localm)
  ```

```gawk
# 1. define a function
# function name(parameter-list){
#     statements
#     return expression
# }

gawk '
function roll2dies(){
  return int(6*rand())+1 int(6*rand())+1 ""
}
BEGIN{
  i=6;
  while(i--){
    print roll2dies();
  }
}
'

# 2. Popular gawk tasks
# 2.1 Print the total for each row
awk '
    {
        # total=0 , unnecessary
        for(i=1; i<= NF; i++)
        {
          total += $i
        }
        printf("The sum of %s = %6d\n", $0, total)
    }
' data.dat

# 2.2 Print the total for each column
awk '
    {
        for (i = 1; i <= NF; i++) {
            t[i] += $i
        }
        print
    }
    END {
        print "  ==="
        for (i = 1; i <= NF; i++) {
            printf("  %7d", t[i])
        }
        printf("\n", "")
     }
' data.dat

# 2.3 Print the minimum and maximum value in column n
awk '
    BEGIN {min = 99999; max = -99999; n=2}
    $n > max {max = $n}
    $n < min {min = $n}
    END {print "Max =", max, "Min =", min}
' data.dat

# 2.4 Filename extension statistics in current folder
find . -iname '*.*' |
awk 'BEGIN {FS = "."}

{exts[$NF]++}

END {
    for (i in exts) { # i is the string index in associate array
        printf("%6d %s\n", exts[i], i) | "sort -nr"
    }
}
' | less

```

* Gawk examples using files from the data folder
  * nationresults.txt
  * regionresults.txt

```bash
# 1. print each line
gawk '{print}'  nationresults.txt

# 2. print all lines match south
gawk '/south/' regionresults.txt

# 3. print specific fields gamer and score from south
gawk '/south/{print $2,$5}' regionresults.txt

# 4. print all gamers whose names start with O
gawk '$2 ~ /^O/' regionresults.txt

# 5. print all gamers whose names start with vowls and their scores
gawk '$2 ~ /^[AEOIU]/{print $2,$5}' regionresults.txt

# 6. print all gamers whose names end with a and their scores
gawk '$2 ~ /a$/{print $2,$5}' regionresults.txt

# 7. print all gamers score between 40 and 50 inclusive
gawk '40<=$5 && $5<=50' regionresults.txt

# 8. print all gamers from Noah to Emma
gawk '/Noah/,/Emma/' nationresults.txt

# 9. skip the first n lines
gawk < nationresults.txt 'BEGIN{
  n=3
}
{
  if (n<=0){
    print;
  }
  n--;
}
'

# 10. print lines between line number a and b
gawk < nationresults.txt 'BEGIN{
  a=3
  b=6
}
{
  if (NR>=a && NR<=b){
    print;
  }
}
'

# 11. sort gamers by score 
sort -nk4 nationresults.txt # in ascending order
sort -r -nk4 nationresults.txt # in descending order

```

## References
* [nawk - pattern-directed scanning and processing language](https://linux.die.net/man/1/nawk)
* [Gawk: Effective AWK Programming](https://www.gnu.org/software/gawk/manual/)
* [handy one-line scripts for awk](https://www.pement.org/awk/awk1line.txt)
* [10 Awk Tips, Tricks and Pitfalls](https://catonmat.net/ten-awk-tips-tricks-and-pitfalls)
* [How to escape a single quote inside awk](https://stackoverflow.com/questions/9899001/how-to-escape-a-single-quote-inside-awk)
* [How to initialize an array of arrays in awk?](https://stackoverflow.com/questions/14063783/how-to-initialize-an-array-of-arrays-in-awk)