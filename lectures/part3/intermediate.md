# Part 3: The shells
*chapter 8-9*

## Intermediate bash programming
* [The Bourne Again Shell - bash (chapter 8)](https://www.gnu.org/software/bash/)
* [Bash programming (chapter 10)](https://tldp.org/LDP/abs/html/)
* [The TC shell (chapter 9)](https://www.tcsh.org/)

*tentative topics*

* control structures
  * conditions: arithmetic and logical expressions
  * branching: if..then, case
  * repetition: while, until, for..in, select
    * break, continue
* script organization
  * input and output
  * function
  * shell variables (local) and environment variables (global)
  * call other scripts inline, trap signals, and kill processes


### control structures
* branching: if..then, case
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
```

* example 2: check script command line arguments
    *  [Usage by here document](https://www.baeldung.com/linux/heredoc-herestring)

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
# script name: lnks
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

* case: case WORD in [PATTERN [| PATTERN]...) COMMANDS ;;]... esac<br>
    Execute commands based on pattern matching.

```bash
help case

#---------------------------------------------------
#!/bin/bash
# script name: answer
read -p "Enter Y or N: " yesorno
case "$yesorno" in
    Y|y|Yes|yes|YES)
        echo "You answered yes"
        ;;
    N|n|No|no|NO)
        echo "You answered no"
        ;;
    *)
        echo "You did not answer"
        ;;
esac
#---------------------------------------------------

```


---

* repetition: while, until, for..in, select
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

for i in $(seq 1 2 10); do
    echo -n "$i "
done
echo

for (( i=0; i<=10; i+=2 )); do
    echo -n "$i"
done
echo
#--------------------

# C-style for loop
#--------------------
#!/bin/bash
# 0 < $RANDOM <32767
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
# script name: whos
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: whos id..." 1>&2
    exit 1
fi
for id # implicitly uses "$@"
do
    gawk -F: '{print $1, $5}' /etc/passwd |
    grep -i "$id"
done
#--------------------
./whos userid1 userid2 userid3 # ...

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

* select: select NAME [in WORDS ... ;] do COMMANDS; done<br>
    Select words from a list and execute commands.

```bash
help select

#---------------------------------------------------
#!/bin/bash
# command menu
#!/bin/bash
PS3="Choose your weapons from the list: "
select w in knife sword arrow bow spear gun cannon missile bomb QUIT
do
    if [ "$w" == "" ]; then
        echo -e "You did not make your choice.\n"
        continue
    elif [ $w = QUIT ]; then
        echo "Thanks for playing the game!"
        break
    fi
echo "You put $w into your bag."
echo -e "It is listed as number $REPLY.\n"
done

#---------------------------------------------------

```

* popular symbol variables

```bash
#---------------------------------------------------
#!/bin/bash
# script name: specialvars
echo "\$0 is the script name: $0"
echo "\$# is number of parameters: $#"
echo "\$@ contains all parameters and put them in an array: $@" # treat each parameter separately
for p in "$@"; do
    echo "$p"
done
echo "\$* contains all parameters and treats them as a single string: $*" # treat all parameters as a single string
for p in "$*"; do
    echo "$p"
done

echo "\$\$ is the PID number of this process: $$"
echo "\$PPIP is the the PID of this process's parent process: $PPID"
echo "\$! is the PID number of most recent background process: $!"
(exit 123)
echo "\$? is the exit status of the preceding command: $?"
echo "\$_ is the last argument of the preceding command: $_"
echo "\$- is the flags of options that are set for the running bash: $- "

# reset positional parameters
oldparams="$@"
set first second third
echo "old parameters \"$oldparams\" are overwritten by \"$@\" "
#---------------------------------------------------

```

---

### script organization
* call other scripts inline: input and output
* function
* shell variables (local) and environment variables (global)
* arrays
* string processing
* arithmetic and logical expressions
* trap signals, and kill processes
* integrate data in script

* call other scripts inline: input and output

```bash
#---------------------------------------------------
# example 1: variables and positional parameters can be passed to a script
#!/bin/bash                                                                  
# script name: guessnum                                                     
                                                                          
# get values from variables passed to the script                             
echo "Hello, ${gamername}, welcome to play Guessing Number!"                 
# the three variables receive values                                         
# passed from positional parameters                                          
DIFFICULTYLEVEL="$1"                                                         
STARTNUM="$2"                                                                
ENDNUM="$3"                                                                  
                                                                             
                                                                             
echo "=== Current Difficulty Level: ${DIFFICULTYLEVEL} ==="                  
echo "guess a number between ${STARTNUM} to ${ENDNUM}"                       
targetnum=$(($RANDOM % ( ${ENDNUM} - ${STARTNUM} ) + ${STARTNUM}))           
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
exit 135
#---------------------------------------------------
# pass variables and positional parameters to guessnum
gamername="Donald Trump" ./guessnum 2 3 8


# example 2: get the output and return value from a script
# get output with command substitution, get return value by saving $?
output=$(gamername="Donald Trump" ./guessnum 2 3 8); ret=$?
echo "${output}"
echo "$ret"
```

* function

```bash
# find all available functions in the current shell
declare -f | more

# define a function
# way 1: 
# functionname () {
#     commands
#     return
# }

showdate()
{
    date
    return 0
}

# way 2
# function name {
#   commands
#   return
# }
function showparams()
{
    # the output of $0 depends on the shell and its options
    echo "the function name is $0" 
    # variables passed to me
    echo "var1=$var1 var2=$var2 var3=$var3"
    # a function has positional parameters similar to script
    echo "$# parameters passed to me:"    
    echo "parameters passed to me:"
    echo "param1=$1 param2=$2 param3=$3 param10=${10}"
    echo "all parameters passed to me: $@"
    echo "all parameters passed to me: $*"

    # return: can only `return' from a function or sourced script
    return 10
}

# pass variables and positional parameters to showparams
output=$(var1=1 var2=2 var3=3 showparams a b c d); ret=$?
echo -e "$output \n $ret"

# use local variables inside a function whenever possible 
# to avoid conflict with global variables
function uselocals()
{
    guser="$USER"
    local USER="Joe Biden"
    echo "Local variable \$USER $USER shadowed global variable \$USER $guser "
}

```

* shell variables (local) and environment variables (global)
    * shell variables are local to each shell process
    * each shell process has its own copy of environment variable inherited from its parent process
    * a shell process can export shell variables into its environment space

```bash
# display variables that are available to the current shell
set

# show all environment variables
printenv
env
export

# show specified environment variabls
# Usage: printenv [OPTION]... [VARIABLE]...
printenv HOME USER

#---------------------------------------------------
#!/bin/bash
# script name: showhu
echo "${USER}'s home is ${HOME}."
#---------------------------------------------------

# modify environment variables in the child shell created by env
# Usage: env [OPTION]... [-] [NAME=VALUE]... [COMMAND [ARG]...]
# Note: not work with builtin commands like echo
./showhu
env HOME="Mother earth" USER="A green tree"  echo "modified HOME=${HOME} and USER=${USER} " 

# run it with an external program or script
env HOME="Mother earth" USER="A green tree"  ./showhu


./showex
# put variables in the environment. 
# put them in .bashrc to for persistency
export pVAR1=value1 pVAR2=value2
# or 
declare -x pVAR1=value1 pVAR2=value2
./showex
#---------------------------------------------------
#!/bin/bash
# script name: showex
echo "\$pVAR1=${pVAR1} \$pVAR2=${pVAR2} ."
#---------------------------------------------------

# export –n or declare +x command 
# removes the export attribute from the named environment variable
export -n pVAR1 pVAR2
# or
declare +x pVAR1 pVAR2
./showex


# Processing null and unset variables
# • Use a default value for the variable.
# ${var:-default} means var=null ? default : var
echo ${username:-${USER}}
echo  $username # username is still null


# • Use a default value and assign that value to the variable.
# ${var:=default} means var <= var=null ? default : var
echo ${username:-${USER}}
echo  $username # username is set to be ${USER} now

# sets variables that are null or unset
# : ${var:=default} # : evaluate its right expression instead of executing it
echo TMPDIR
: ${TMPDIR:=/tmp}
echo TMPDIR

# • Display an error.
# set –o nounset causing bash to display an error message
# and exit from a script whenever the script references an unset variable.
set -o nounset
unset TMPDIR
echo $TMPDIR # prints "TMPDIR: unbound variable"
# :? sends an error message to standard error
echo ${TMPDIR:?"TMPDIR is not set yet."}

```

* arrays: indexed arrays (indexed from 0) and associate arrays

```bash
# create arrays
arr1[1]=apple
echo ${arr1[1]}

declare -a arr2
echo ${arr2[1]}

declare -a | grep -i arr

# assign values to arrays
arr1[10]=grape
arr2[5]=10
echo "arr1[10]=${arr1[10]}  arr2[5]=${arr2[5]}"
declare -a | grep -i arr

colors=(red blue green yellow pink dark black grey white)
days=([3]=Wen [7]=Sun)
declare -a | grep -i "colors\|days"

# print the entire contents of arrays
for c in ${days[@]}; do echo $c; done
for c in ${days[*]}; do echo $c; done

for c in "${days[@]}"; do echo $c; done
for c in "${days[*]}"; do echo $c; done

# find the number of array elements
echo ${#colors[@]}
echo ${#days[@]}
echo ${#colors[*]}
echo ${#days[*]}

# find the subscripts used by an array
echo ${!colors[@]}
echo ${!days[@]}
echo ${!colors[*]}
echo ${!days[*]}

# append new elements
days+=(Tue Fri)
declare -a | grep -i "days"

# sort an array. The sort command sorts column only
sortedcolors=($(for c in "${colors[@]}"; do echo $c; done | sort))
echo "${sortedcolors[@]}"

# delete array elements, arrays
declare -a | grep -i "days"
unset 'days[3]'
declare -a | grep -i "days"
unset days
declare -a | grep -i "days"

# associate arrays
declare -A scores
scores["Mike"]=100
scores["Biden"]=98
scores["Trump"]=89

echo "${scores[Trump]}"
declare -A | grep scores

scores+=([Lins]="102" [Lius]="103")
declare -A | grep scores
echo "${scores[Lius]}"
echo "${scores[@]}"
echo "${scores[*]}"
echo "${#scores[@]}"
echo "${#scores[*]}"

```

* string processing

```bash
# example 1: parameter expanion
a=good
echo "$a is ${a}"
echo "a_$a_man is not a_${a}_man"

echo "$10 is not ${10}"

# example 2: expansions that return variable names
agoodday="a good day"
echo "${!ag*} is ${!ag@}"

# example 3: string operations
# 3.1 get the length of a string
echo "The length of '${agoodday}' is '${#agoodday}'"

# 3.2 substring

astring=0123456789abcdef
# ${var:offset}
echo "The substring starting from index 10 to the end of '$astring' is '${astring:10}'"
# ${var:offset:length}
echo "The substring starting from index 5 with length 5 of '$astring'  is '${astring:5:5}'"
# ${var: -offset:length} # negative index counts from right starting from -1
echo "The last 5 characters of '$astring'  are '${astring: -5}'"
echo "The last 5 characters of '$astring'  are '${astring: -5:5}'"

# 3.3 remove substrings matched patterns from left
mypath="a good man.txt.gz"
#  ${var#pattern}, remove the shortest match
echo ${mypath#*.}

# ${var##pattern}, remove the longest match
echo ${mypath##*.}

# 3.4 remove substrings matched patterns from right
# ${var%pattern}, remove the shortest match
echo ${mypath%.*}
# ${var%%pattern}, remove the longest match
echo ${mypath%%.*}

# 3.5 substring search-and-replace
apoem=$(cat <<+++
“God alone is enough.”
Let nothing upset you,
let nothing startle you.
All things pass;
God does not change.
Patience wins
all it seeks.
Whoever has God
lacks nothing:
God alone is enough.
My lord God bless you!
+++
)

echo $apoem
# is not
echo "$apoem" # a string contains many lines

gog="God is a great God" # a string contains a single line

# ${var/pattern/string} - replace the first occurrence only
echo "${apoem/God/Goddess}"
# ${var//pattern/string} - replace all occurrences
echo "${apoem//God/Goddess}"
# ${var/#pattern/string} - match occur at the beginning of the string, NOT A LINE
echo "${apoem/#God/Goddess}" 
echo ${gog/#God/Goddess}
# ${var/%pattern/string} - match occur at the end of the string, NOT A LINE
echo "${apoem/%God/Goddess}"
echo ${gog/%God/Goddess}

#---------------------------------------------------
#!/bin/bash
# longword: find longest string in a file

for f; do
    if [[ -r "$f" ]]; then
        longestword=
        maxlen=0
        for w in $(strings $f); do
            len="${#w}"
            if ((len > maxlen)); then
                maxlen="$len"
                longestword="$w"
            fi
        done
        echo "$f: '$longestword' ($maxlen characters)"
    fi
done
#---------------------------------------------------

# 4. case conversion
# 4.1 declare - forces a variable to always contain the desired format
# no matter what is assigned to it.

#---------------------------------------------------
#!/bin/bash
# script name: normcase
declare -u myupper
declare -l mylower

if [[ "$1" ]]; then
    myupper="$1"
    mylower="$1"
    echo "always upper: $myupper"
    echo "always lower: $mylower"
fi
#---------------------------------------------------
./normcase "God is still your God"

# 4.2 case conversion by parameter expansion
# the bash pattern below limits which characters are converted
# ${var,,pattern} - expand $var and convert each character into lowercase
# ${var,pattern} - expand $var and convert the first character into lowercase
# ${var^^pattern} - expand $var and convert each character into uppercase
# ${var^pattern} - expand $var and convert the first character into uppercase

expancase(){
    if [[ -n "$1" ]]; then
        echo "${1,,}"
        echo "${1,}"
        echo "${1^^}"
        echo "${1^}"
    fi
}

expancase "Hello, How are you?"

```

* arithmetic expressions
  * the shell’s arithmetic operates only on integers
    * the results of division are always integers.

```bash
# 1. literal integer numbers with different bases
fnums(){
    if [ "$#" -lt 2 ]; then
        echo "Usage: fnums num1 num2"
        return 1
    fi
    local num="$1"
    local base="$2"
    echo "decimal number ${num}: $((num))"
    echo "octal number 0${num}: $((0${num}))"
    echo "hex number 0x${num}: $((0x${num}))"
    echo "base#number ${base}#${num} : $((${base}#${num}))"
}

fnums 1201 3
fnums 12061 7

# 2. arithmetic operators
farithops(){
    if [ "$#" -lt 2 ]; then
        echo "Usage: fnums num1 num2"
        return 1
    fi    
    echo "unary operators"
    echo "+${1}=$((+${1}))  -${1}=$((-${1}))"
    echo "binary operators"
    echo "${1}+${2} = $((${1}+${2}))"
    echo "${1}-${2} = $((${1}-${2}))"
    echo "${1}*${2} = $((${1}*${2}))"
    echo "${1}/${2} = $((${1}/${2}))"
    echo "${1}**${2} = $((${1}**${2}))"
    echo "${1}%${2} = $((${1}%${2}))"
}

farithops 5 2
farithops 12 21

# [leap year](https://en.wikipedia.org/wiki/Leap_year)
# if (year is not divisible by 4) then (it is a common year)
# else if (year is not divisible by 100) then (it is a leap year)
# else if (year is not divisible by 400) then (it is a common year)
# else (it is a leap year)
leapyear(){
    while [[ -n "$1" ]]; do
        if (($1%4 != 0)); then
            echo "$1 is a common year"
        elif (( $1%100 != 0 )); then
            echo "$1 is a leap year"
        elif (( $1%400!=0 )); then
            echo "$1 is a common year"
        else
            echo "$1 is a leap year"
        fi
        shift
    done
}

leapyear {995..1005}

# given an integer, 
# find its odd digits and their sum, average

foddsa(){
    # use $1 as the integer
    local ndigits=${#1}
    local count=0
    local sum=0
    echo -n "odd digits of ${1}: "
    for ((i=0; i<ndigits; i++)); do
        d=${1:i:1}
        if (( d%2==1 )); then
            odddigits[$i]=$d
            echo -n "$d "
            ((sum+=d))
            ((count++))
        fi
    done
    echo -e "\nThe sum of odd digits of ${1}: ${sum}"
    average=$(echo "${sum}/${count}" | bc -l)
    printf "The average of odd digits of ${1}: %.2f\n" "${average}"
}

foddsa 31415926

# 3. augmented assignment
faug(){
    ((a="${1}", b="${2}"))
    echo "((a="${1}", b="${2}")): \$a=$a, \$b=$b"
    ((a += b))
    echo "((a += b)): \$a=$a, \$b=$b"
    ((a -= b))
    echo "((a -= b)): \$a=$a, \$b=$b"
    ((a *= b))
    echo "((a *= b)): \$a=$a, \$b=$b"
    ((a /= b))
    echo "((a /= b)): \$a=$a, \$b=$b"
    ((a %= b))
    echo "((a %= b)): \$a=$a, \$b=$b"
    ((a++, b--))
    echo "((a++, b--)): \$a=$a, \$b=$b"
    ((++a, --b))
    echo "((++a, --b)): \$a=$a, \$b=$b"
}

faug 123 2

foo=1; echo $foo; echo $((foo++)); echo $foo
foo=1; echo $foo; echo $((++foo)); echo $foo


# 4. bitwise operation
fbitops(){
    a="$1"
    b="$2"

    echo "\$a=$a($(echo -e "obase=2\n $a\n" | bc)), \$b=$b($(echo -e "obase=2\n $b\n" | bc))"
    # echo "\$a=$(echo -e "obase=2\n $a\n" | bc), \$b=$(echo -e "obase=2\n $b\n" | bc)"
    # bitwise negation
    # https://en.wikipedia.org/wiki/Two%27s_complement
    ((ar=~a, br=~b))
    echo "~\$a=$ar($(echo -e "obase=2\n $ar\n" | bc)), ~\$b=$br($(echo -e "obase=2\n $br\n" | bc))"

    # left shift
    echo -n "((a<<b)): "
    ((r=a<<b))
    echo "$r($(echo -e "obase=2\n $r\n" | bc))"

    # right shift
    echo -n "((a>>b)): "
    ((r=a>>b))
    echo "$r($(echo -e "obase=2\n $r\n" | bc))"

    # bitwise and
    echo -n "((a&b)): "
    ((r=a&b))
    echo "$r($(echo -e "obase=2\n $r\n" | bc))"

    # bitwise or
    echo -n "((a|b)): "
    ((r=a|b))
    echo "$r($(echo -e "obase=2\n $r\n" | bc))"

    # bitwise xor
    echo -n "((a^b)): "
    ((r=a^b))
    echo "$r($(echo -e "obase=2\n $r\n" | bc))"

}

fbitops 8 3

# 5. logic expressions follow the rules of arithmetic logic
# 0 - false, nonzero - true; which is contrary to command exit status
((1)) && echo true || echo false
(exit 0) && echo true || echo false

((0)) && echo true || echo false
(exit 1) && echo true || echo false

flogic(){
    echo "(($1 <= $2)) : $(($1<=$2))"
    echo "(($1 >= $2)) : $(($1>=$2))"
    echo "(($1 < $2)) : $(($1<$2))"
    echo "(($1 > $2)) : $(($1>$2))"
    echo "(($1 == $2)) : $(($1==$2))"
    echo "(($1 != $2)) : $(($1!=$2))"
    echo "(($1 && $2)) : $(($1&&$2))"
    echo "(($1 || $2)) : $(($1||$2))"
    echo "(($1 == $2?$1:$2 )): $(($1 == $2?$1:$2))"
}

flogic 3 4

# recursion function: factorial
factorial(){
    n="$1"
    if (( n<=1)); then
        echo 1
    else
        echo $(( n * $(factorial $((n-1))) ))
    fi
}
# recursion function: find the sum of odd digits of an integer
fsumodd(){
    n="$1"
    if [[ ${#n} -eq 1 ]]; then
        echo $((n%2==1?n:0))
    else
        h="${n:0:1}"
        t="${n:1}"
        hs=$((h%2==1?h:0))
        echo $((hs+ $(fsumodd $t)))
    fi
}

fsumodd 31415926

fsumodd2(){
    if (($1<10)); then
        echo $(($1%2==1?$1:0))
    else
        q=$(($1/10))
        r=$(($1%10))
        rs=$((r%2==1?r:0))
        echo $((rs+$(fsumodd2 $q)))
    fi
}

fsumodd2 31415926

# mkpath - implement mkdir -p 
mkpath(){
    if [[ ${#1} -eq 0 || -d "$1" ]]; then
        echo "path is empty or existant"
        return 0
    fi
    if [[ "${1%/*}" = "$1" ]]; then
        mkdir "$1"; return $?
    fi
    mkpath "${1%/*}" || return 1
    mkdir "$1"; return $?
}

```

---

* logical expressions
  * [[ ... ]]: [[ expression ]]<br>
    Execute conditional command.

```bash
help [[

# example 1. comparison, -eq,-ne,-gt,-lt,-ge,-le
# && = -a, || = -o

grade(){
    if [[ $1 -lt 0 || $1 -gt 100 ]]; then
        echo "$1 is invalid"
    elif [[ $1 -ge 90 ]]; then
        echo "$1 is A"
    elif [[ 80 -le $1 && $1 -lt 90  ]]; then
        echo "$1 is B"
    elif [[ $1 -ge 70 && $1 -lt 80 ]]; then
        echo "$1 is C"
    elif [[ $1 -ge 60 && $1 -lt 70 ]]; then
        echo "$1 is D"
    else
        echo "$1 is F"
    fi
}

for (( i=-10; i<120; i+=20)); do grade $i; done

# string comparison and pattern match

comstr(){
    if [[ $1<$2 ]]; then
        echo "$1 is before $2"
    elif [[ $1>$2 ]]; then
        echo "$1 is after $2"
    else
        echo "$1 matches $2"
    fi
}

comstr good bad; comstr good good; comstr bad good

[[ goodie = goo* ]] && echo matched || echo "not matched"


```

---

* command line option processing with [getopt](https://wiki.bash-hackers.org/howto/getopts_tutorial)
  * getopts: getopts optstring name [arg ...]<br>
    Parse option arguments.
    * optstring is a list of the valid option letters, 
    * name is the variable that receives the options one at a time, 
    * arg is the optional list of parameters to be processed
    *  If arg is not present, getopts processes the command-line arguments. 
    *  If optstring starts with a colon (:), the script must take care of generating error messages; otherwise, getopts generates error messages
    *  It uses the OPTIND (option index) and OPTARG (option argument) variables to track and store option-related values
    *  When a shell script starts, the value of OPTIND is 1. 
       *  Each time getopts is called and locates an argument, it increments OPTIND to the index of the next option to be processed. 
       *  If the option takes an argument, bash assigns the value of the argument to OPTARG
    * To indicate that an option takes an argument, follow the corresponding letter in optstring with a colon (:)
    *  ignore all other options and end option processing when it encounters two hyphens (--)

```bash
getopts --help

#--------------------------------------------------------
#!/bin/bash
# script name: setdiff
DIFFICULTYLEVEL=1
while getopts :c:h arg; do
    case "$arg" in
        c)
            if [[ ! "$OPTARG" =~ [123] ]]; then
                echo "error: difficulty level can only be 1,2, or 3"
                exit 1
            else
                DIFFICULTYLEVEL=$OPTARG
                echo "difficulty level is set to be $DIFFICULTYLEVEL"
            fi
            ;;
        h)
            cat <<-USAGE
                "${0##*/}" -c difficulty-level or
                "${0##*/}" -h show help message
USAGE
        ;;
        :) #  for an option missing an argument, name is set to : and OPTARG to the option letter
        echo "${0##*/}: invalid arg"
        ;;
        \?) # for an invalid option, name is set to ? and OPTARG to the option letter
        echo "${0##*/}: invalid options"
        ;;
    esac 
done
echo "current difficulty level: $DIFFICULTYLEVEL"
#--------------------------------------------------------

# or process options with pattern match
#--------------------------------------------------------
#!/bin/bash
# script name: setdiff2
DIFFICULTYLEVEL=1
while [[ "$1" = -* ]]; do # pattern match
    case "$1" in
        -c)
            if [[ ! "$2" =~ [123] ]]; then
                echo "error: difficulty level can only be 1,2, or 3"
                exit 1
            else
                DIFFICULTYLEVEL=$2
                echo "difficulty level is set to be $DIFFICULTYLEVEL"
            fi
            break
            ;;
        -h)
            cat <<-USAGE
                "${0##*/}" -c difficulty-level or
                "${0##*/}" -h show help message
USAGE
        break
        ;;
        --) # stop processing options
            break
        ;;
        *) # for an invalid option
        echo "${0##*/}: invalid options: $@"
        break
        ;;
    esac 
done
echo "current difficulty level: $DIFFICULTYLEVEL"
#--------------------------------------------------------

```

* integrate data in script with [here document](https://www.baeldung.com/linux/heredoc-herestring)

```bash

#---------------------------------------------------
#!/bin/bash
# script name: lookup boxername

# here document for multiple-lines text
# The delimiter token can be any value as long as 
# it is unique enough that it won’t appear within the content. 
# example 1: the delimiter is +
# the - symbol after << suppresses the tab indentations in the output
cat <<-+
    Usage: this line begins with a tab. The tab will be suppressed from the output
    This line begins with 4 spaces, they will be kept in the output
    Special Characters need escaping: \$ \\ \`
+

# here document for messages spanning several lines
# example 2: the delimiter is HELPMSG
cat <<HELPMSG
    Day 1: exercise
    Day 2: learn Introduction to Unix
    Day 3: go shopping
HELPMSG

# example 3: the delimiter is DATA
# DATA here serves as delimiter
grep -i "$1" <<DATA 
Boxer,date,times of wins
Mike Foo,February 10,12
Mike Tason,June 3,100
Muhamed Ali, September 4, 123
DATA


# example 4: the delimiter is @
# heredoc with parameter substitution and command substitution
cat <<@
I, ${USER}, a gentle man?!
Today is $(date) 
shown in calendar 
$(cal)
@

# example 5: show block of code as text
cat <<'SHOWASTEXT'
echo prints out everything after echo
I, ${USER}, a gentle man?!
Today is $(date) 
SHOWASTEXT

# example 6: pass arguments to function with heredoc
function logintoember()
{
    read -p "Your login id: " loginid
    read -p "Login password: " password
    echo "${loginid} will be logged onto ember with password ${password}"
}

logintoember <<LOGINCREDENTIAL
Administrator123
P@ssw0rd
LOGINCREDENTIAL

# example 7: herestring - a quick way to redirect some strings into a command.

cat <<< "Hi ${USER}, Welcome to ember! Now is $(date) "

#---------------------------------------------------
```

* [trap](https://www.baeldung.com/cs/os-trap-vs-interrupt) and [signal](https://www.baeldung.com/linux/sigint-and-other-termination-signals)

```bash
#---------------------------------------------------
#!/bin/bash
# script name: locktty
trap '' 1 2 3 18
stty -echo
read -p "Key: " key1
echo
read -p "Again: " key2
echo
key_3=
if [ "$key1" = "$key2" ]
    then
        tput clear
        until [ "$key3" = "$key2" ]
        do
           read key3
        done
    else
        echo "locktty: keys do not match" 1>&2
fi
stty echo
#---------------------------------------------------
```

* trap signals, and kill processes

---


## References
* [Bash Shell Scripting](https://en.wikibooks.org/wiki/Bash_Shell_Scripting)
  * [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
    * [on github](https://github.com/pmarinov/bash-scripting-guide)
    * [in HTML](https://hangar118.sdf.org/p/bash-scripting-guide/index.html)
* [The Linux Command Line](https://linuxcommand.org/)
  * [Making menus with select](https://linuxize.com/post/bash-select/)
  * [Signals in Linux](https://linuxcent.com/signals-in-linux/)