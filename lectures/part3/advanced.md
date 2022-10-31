# Part 3: The shell
*chapter 14-1*

* [The Bourne Again Shell - bash (chapter 8)](https://www.gnu.org/software/bash/)
* [Bash programming (chapter 10)](https://tldp.org/LDP/abs/html/)
* [The TC shell (chapter 9)](https://www.tcsh.org/)
* [tput, dialog and SQL](http://linuxcommand.org/lc3_adventures.php)


## Advanced bash programming

* [Regular expression](https://en.wikipedia.org/wiki/Regular_expression)
  * A regular expression defines a set of one or more strings of characters. 
    * A simple string of characters is a regular expression that defines one string of characters: itself. 
  * A more complex regular expression uses letters, numbers, and special characters to define many different strings of characters.
  *  A regular expression is said to match any string it defines.
  * regular expressions are widely used by ed, vim, emacs, grep, mawk/gawk, sed, Perl, and many other utilities. NOTE: THEY MAY SUPPORT DIFFERENT SETS OF REGEX
  * [test regex online](https://regex101.com/)

```bash
#  grep [OPTION]... PATTERNS or regex [FILE]...
# Search for PATTERNS or regex in each FILE.
# 1. a literals string has no meta characters  
# A literal string matches only itself
ls /bin/ | grep zip # all program names contain zip

ls /bin/ | grep -v zip # -v:inverse match, all program names contain no zip

# 2. Metacharacters
# ^ $ . [ ] { } - ? * + ( ) | \
# 2.1 A period (.) matches any single character
ls /bin/ | grep .zip
ls /bin/ | grep zip.
ls /bin/ | grep .zip.

# 2.2 The caret (^) and dollar sign ($) characters 
# are treated as anchors in regular expressions.
# they cause the match to occur only 
# if the regular expression is found 
# at the beginning of the line (^) or 
# at the end of the line ($)

ls /bin | grep '^zip' # begin with zip
ls /bin | grep 'zip$' # end with zip
ls /bin | grep '^zip$' # only zip

# 2.3 bracket expressions and character classes
grep '[abcdefg]zip' <<<$(ls /bin)

# A set may contain any number of characters
# ( the relation between them is or )
# and metacharacters lose their special meaning when placed within brackets. 
# except the caret (^) means negation; 
# the dash (-), means a character range
grep '[^a-g]zip' <<<$(ls /bin)
ls /bin | grep '[^A-Za-z0-9]'


```

* POSIX Character classes

The [POSIX standard](https://en.wikipedia.org/wiki/POSIX) supports the following classes or categories of characters (note that classes must be defined within brackets):

| **POSIX class** | **Equivalent to** | **Matches** | 
| --- | --- | --- |
| `[:alnum:]` | `[A-Za-z0-9]` | digits, uppercase and lowercase letters |
| `[:alpha:]` | `[A-Za-z]` | upper- and lowercase letters |
| `[:ascii:]` | `[\x00-\x7F]` | ASCII characters |
| `[:blank:]` | `[ \t]` | space and TAB characters only |
| `[:cntrl:]` | `[\x00-\x1F\x7F]` | Control characters |
| `[:digit:]` | `[0-9]` | digits |
| `[:graph:]` | `[^ [:cntrl:]]` | graphic characters (all characters which have graphic representation) |
| `[:lower:]` | `[a-z]` | lowercase letters |
| `[:print:]` | `[[:graph:] ]` | graphic characters and space |
| `[:punct:]` | ``[-!"#$%&'()*+,./:;<=>?@[]^_`{\|}~]`` | all punctuation characters (all graphic characters except letters and digits) |
| `[:space:]` | `[ \t\n\r\f\v]` | all blank (whitespace) characters, including spaces, tabs, new lines, carriage returns, form feeds, and vertical tabs |
| `[:upper:]` | `[A-Z]` | uppercase letters |
| `[:word:]` | `[A-Za-z0-9_]` | word characters |
| `[:xdigit:]` | `[0-9A-Fa-f]` | hexadecimal digits |

* Examples
  * `a[[:digit:]]b` matches `a0b`, `a1b`, ..., `a9b`.
  * `a[:digit:]b` is invalid, character classes must be enclosed in brackets
  * `[[:digit:]abc]` matches any digit, as well as `a`, `b`, and `c`.
  * `[abc[:digit:]]` is the same as the previous, matching any digit, as well as `a`, `b`, and `c`
  * `[^ABZ[:lower:]]` matches any character except lowercase letters, `A`, `B`, and `Z`.

```bash
ls /usr/sbin/[ABCDEFGHIJKLMNOPQRSTUVWXYZ]*
ls /usr/sbin/[A-Z]*
ls /usr/sbin/[[:upper:]]*

```

* POSIX regular expression implementations have two kinds: 
  * basic regular expressions (BRE) supports metacharacters: '^ $ . [ ] *'
  * extended regular expressions (ERE) supports more metacharacters: '( ) { } ? + |'
  * the (, ), {, and } characters are treated as metacharacters in BRE if they are escaped with a backslash, whereas with ERE, preceding any metacharacter with a backslash causes it to be treated as a literal

```bash
# 1. Alternation allows matches from a set of strings or other regular expressions
ls /bin | grep -E 'un|non' # contains un or non
ls /bin | grep 'un\|non'
ls /bin | egrep 'un|non'


ls /bin | egrep '^(bz|gz|xz)' # begins with bz, gz or zx

# 2. quantifier specifys the number of times an element is matched
# ? - zero or one time, for optional element
echo "863-583-9050" | egrep '^\(?[0-9][0-9][0-9]\)?-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
echo "(863)-583-9050" | egrep '^\(?[0-9][0-9][0-9]\)?-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
echo "863)-583-9050" | egrep '^\(?[0-9][0-9][0-9]\)?-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
echo "(863-583-9050" | egrep '^\(?[0-9][0-9][0-9]\)?-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'

# * - zero or more times, for optional element,
#     may occur any number of times, not just once
echo 'Today is a wonderful day!' | egrep '[[:upper:]][[:upper:][:lower:] ]*\.'
echo 'Today is a wonderful day.' | egrep '[[:upper:]][[:upper:][:lower:] ]*\.'
echo 'today is a wonderful day.' | egrep '[[:upper:]][[:upper:][:lower:] ]*\.'

# + - one or more times
echo 'match only the lines consisting of groups of 
one or more alphabetic characters separated by single space' | 
egrep '^([[:alpha:]]+ ?)+$'

# {} - specific number of times
# {n} - n times
# {n,m} - n to m times
# {n,} - at least n times
# {,m} - at most m times
echo "863-583-9050" | egrep '^\(?[0-9]{3}\)?-[0-9]{3}-[0-9]{4}'
echo "(863)-583-9050" | egrep '^\(?[0-9]{3}\)?-[0-9]{3}-[0-9]{4}'
echo "863)-583-9050" | egrep '^\(?[0-9]{3}\)?-[0-9]{3}-[0-9]{4}'
echo "(863-583-9050" | egrep '^\(?[0-9]{3}\)?-[0-9]{3}-[0-9]{4}'


# find all file names contain at least one digit
find . -regex '.*[0-9]+.*'
locate --regex 'bin/(bz|gz|xz)'

# search text with less or vim
ls /bin | less
 
```

---

* tput


---

* dialog

---

* SQL

---

## References
* [Bash Shell Scripting](https://en.wikibooks.org/wiki/Bash_Shell_Scripting)
  * [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
    * [on github](https://github.com/pmarinov/bash-scripting-guide)
    * [in HTML](https://hangar118.sdf.org/p/bash-scripting-guide/index.html)
* [The Linux Command Line](https://linuxcommand.org/)
* [Regular expression](https://www.regular-expressions.info/)