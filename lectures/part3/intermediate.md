# Part 3: The shells
*chapter 8-9*

## Intermediate bash programming
* [The Bourne Again Shell - bash (chapter 8)](https://www.gnu.org/software/bash/)
* [Bash programming (chapter 10)](https://tldp.org/LDP/abs/html/)
* [The TC shell (chapter 9)](https://www.tcsh.org/)

*tentative topics*

* control structures
  * conditions: arithmetic and logical expressions
  * branching: if..then, case, select
  * repetition: while, until, for..in, 
    * break, continue
* script organization
  * input and output
  * function
  * shell variables (local) and environment variables (global)
  * call other scripts inline, trap signals, and kill processes


### control structures
* branching: if..then, case, select
* conditions: arithmetic and logical expressions

```bash
# find the help
help if
help case
help select

# if test-command
# then
#    commands
# fi
help test

```

* example 1: [string comparison](https://linuxize.com/post/how-to-compare-strings-in-bash/)
  * [test command](https://kapeli.com/cheat_sheets/Bash_Test_Operators.docset/Contents/Resources/Documents/index)
  * [ \[ is another name for the test command ](https://unix.stackexchange.com/questions/306111/what-is-the-difference-between-the-bash-operators-vs-vs-vs)

```bash
#--------------------
#!/bin/bash
# script name: compstr 
read -p "string 1: " str1
read -p "string 2: " str2

if test "$str1" = "$str2"; then # a semicolon (;) ends a command just as a NEWLINE does
    echo "two strings match"
elif test "$str1" \< "$str2" 
then # escape <
    echo "$str1 is before $str2 in lexicographical order"
else
    echo "$str1 is after $str2 in lexicographical order"    
fi
#--------------------

* example 2: check script command line arguments

```bash
#--------------------
#!/bin/bash
# script name: atleastone
if [ $# -eq 0 ] ; then
    echo "Usage: $0 [-v] filenames..."  1>&2
    exit 1
fi

if [ "$1" = "-v" ]; then
    shift # shift the command parameters one position left
    less -- "$@" # the – – argument to cat and less tells these utilities 
    # that no more options follow on the command line and not to consider 
    # leading hyphens (–) in the following list as indicating options
else
    cat -- "$@"
fi        
#--------------------

#--------------------
#!/bin/bash
# script name: argnum2
if test $# -ne 2; then
    echo "exactly two parameters are needed" 
    exit 1
fi

echo "arg1=$1; arg2=$2"
#--------------------
```

* example 3: compare two files

```bash

#!/bin/bash
# script name: compfile
if test $# -ne 2; then
    echo "exactly two parameters are needed" 
    exit 1
fi

if  test ! -e "$1" -o  ! -e "$2"; then
    echo "$1 or $2 not exist!"
    exit 2
fi

if test -f "$1" -a  -f "$2" ; then
    if test "$1" -nt "$2"; then
        echo "$1 is newer than $2"
    elif test "$1" -ot "$2"; then
        echo "$1 is older than $2"
    else
        echo "$1 $2 are updated at the same time"
    fi 
fi
```

* example 4: find hard links to a file in a directory hierarchy

```bash

#!/bin/bash
# script name: hardlinks
# Identify links to a file
# Usage: lnks file [directory]

if [ $# -eq 0 -o $# -gt 2 ]; then 
    echo "Usage: lnks file [directory]" 1>&2
    exit 1
fi
if [ -d "$1" ]; then
    echo "First argument cannot be a directory." 1>&2
    echo "Usage: lnks file [directory]" 1>&2
    exit 2
else
    file="$1"
fi
if [ $# -eq 1 ]; then
        directory="."
    elif [ -d "$2" ]; then
        directory="$2"
    else
        echo "Optional second argument must be a directory." 1>&2
        echo "Usage: lnks file [directory]" 1>&2
        exit 3
fi

# Check that file exists and is an ordinary file
if [ ! -f "$file" ]; then
    echo "lnks: $file not found or is a special file" 1>&2
    exit 4
fi
# Check link count on file
set -- $(ls -l "$file") # set the positional parameters to the output of ls –l
# The -- prevents set from interpreting as an option 
# the first argument produced by ls –l begins with -

linkcnt=$2
if [ "$linkcnt" -eq 1 ]; then
    echo "lnks: no other hard links to $file" 1>&2
    exit 0
fi

# Get the inode of the given file
set $(ls -i "$file")

inode=$1

# Find and print the files with that inode number
echo "lnks: using find to search for links..." 1>&2

find "$directory" -xdev -inum $inode -print # –xdev (cross-device) argument 
# prevents find from searching directories on other filesystems
```

---

* repetition: while, until, for..in, 
  * break, continue

```bash
#  for NAME [in WORDS ... ] ; do COMMANDS; done
# If `in WORDS ...;' is not present, then `in "$@"' is assumed
help for

# example 1: loop through word list
#--------------------
#!/bin/bash
# script name: forwords
echo -n "You are so "
for adj in great good nice generous kind magnanimous; do
    echo -n "$adj, "
done
echo  
#--------------------  

# shell expands wildcard into a wordlist (file list) 
#--------------------
#!/bin/bash
# script name: forfiles
for f in *
do
    if [ -f "$f" ]; then
        echo "$f"
    fi
done 
#--------------------

# shell expands curly brackets
#--------------------
#!/bin/bash
# script name: fornums
for i in {1..10..2}; do # {start..stop..step}
    echo -n "$i "
done
echo
#--------------------

# C-style for loop
#--------------------
#!/bin/bash
# script name: forcstyle
for ((i=1; i<=10; i++)); do
    echo -n "Rolling two dies #$i: "
    echo -n $(( $RANDOM % 6 + 1 )) " "
    echo $(( $RANDOM % 6 + 1 ))
done
echo
#--------------------

# Without a wordlist, for use $@
# the shell expands "$@" into a list of quoted 
# command-line arguments (i.e., "$1" "$2" "$3" ...)
#--------------------
#!/bin/bash
# script name: forargs
for arg; do
    echo -n "$arg "
done
echo
#--------------------

# Print user's information
#--------------------
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: whos id..." 1>&2
    exit 1
fi
for id
do
    gawk -F: '{print $1, $5}' /etc/passwd |
    grep -i "$id"
done
#--------------------

# while loop
#  while COMMANDS; do COMMANDS; done
#  Execute commands as long as a test succeeds
help while

# roll two dies with while
#--------------------
#!/bin/bash
# script name: rolldies
i=1
while [ "$i" -le 10 ]; do
    echo -n "Rolling two dies #$i: "
    echo -n $(( $RANDOM % 6 + 1 )) " "
    echo $(( $RANDOM % 6 + 1 ))
    ((i++))
done
echo
#--------------------

#--------------------
#!/bin/bash
# script name: cleanspell
# remove misspellings from aspell output

if [ $# -ne 2 ]; then
    echo "Usage: cleanspell dictionary filename" 1>&2
    echo "dictionary: list of correct spellings" 1>&2
    echo "filename: file to be checked" 1>&2
    exit 1
fi

if [ ! -r "$1" ] || [ ! -r "$2" ]; then
    echo "cleanspell: $1 or $2 is unreadable" 1>&2
    exit 2
fi

aspell list < "$2" |
while read line; do
    if grep "^$line$" "$1" > /dev/null; then
        echo $line
    fi
done
#--------------------

# until - until COMMANDS; do COMMANDS; done
# Execute commands as long as a test does not succeed
#--------------------
#!/bin/bash
# script name: guessnum
echo "guess a number between 1 to 100"
targetnum=$(($RANDOM % 100 + 1))
num=1
echo
until [ $num -eq $targetnum ]; do
    read -p "Your guess: " num
    if [ $num -gt $targetnum ]; then
        echo "too large"
    else
        echo "too small"
    fi
done
echo "Congratulation! You get it!"

#--------------------


```
---


## References
* [Bash Shell Scripting](https://en.wikibooks.org/wiki/Bash_Shell_Scripting)
  * [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
    * [on github](https://github.com/pmarinov/bash-scripting-guide)
    * [in HTML](https://hangar118.sdf.org/p/bash-scripting-guide/index.html)
* [The Linux Command Line](https://linuxcommand.org/)