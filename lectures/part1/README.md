# Part 1: The Linux operating systems
*chapter 1-5*

# Introduction
*chapter 1-2*

## Topics
* [Linux](https://en.wikipedia.org/wiki/Linux)
  * [Unix](https://en.wikipedia.org/wiki/Unix)
  * [Timeline of operating systems](https://en.wikipedia.org/wiki/Timeline_of_operating_systems)
* [Linux distribution](https://en.wikipedia.org/wiki/Linux_distribution)
  * [Linux kernel](https://en.wikipedia.org/wiki/Linux_kernel)
    * [The Linux Kernel Archives](https://www.kernel.org/)
  * [List of Linux distributions](https://en.wikipedia.org/wiki/List_of_Linux_distributions)

## Demos and practices

### setup a Linux environment
  * [Setup Ubuntu mate in VirtualBox](https://youtu.be/ZGJi20F2eqA)
  * Access ember.hpc.lab through [VPN](https://vpn.floridapoly.edu/) and [Putty](https://www.putty.org/)
  * [Google Colab](https://colab.research.google.com/)
  * [Alibaba Cloud](https://us.alibabacloud.com/), [Amazon AWS](https://aws.amazon.com/), [Baidu AI Cloud](https://login.bce.baidu.com/), [Microsoft Azure](https://azure.microsoft.com/)

### Get started
*chapter 2*

  * Logging from a terminal
  ```bash
  # login locally
  # login remotely
  ssh urname@ember.hpc.lab
  # investigate the welcome message
  ```
  * Working from command line
  ```bash
  # use a emulator
  # open a textual interface
  ```
  * Which shell are you running
  ```bash
  echo $0
  echo $SHELL
  ```
  * Correcting mistakes
  ```bash
  # CTRL+H: delete the last character as BACKSPACE
  # CTRL+W: delete the last word
  # CTRL+U: kill a line
  # CTRL+J: delete the whole line
  # CTRL+Z: suspends a program
  # jobs" list background processes
  # fg: bring the last backgroud process to foreground
  # kill: kill a job or process
  bigjob
  ^Z
  jobs
  kill -TERM %1
  ```
  * Repeating/editing command lines
  ```bash
  # use arrow key to browse history commands
  # repeat the previous command using !!
  cat meno
  #  ^old^new^ reruns the previous command, substituting the first occurrence of the string old with new
  ^n^m^
  #  !$ is the last token (word) on the previous command line
  ls !$
  ```
  * su/sudo: curbing your power (root privileges)
  ```bash
  ls -l /lost+found
  # enter privilege mode
  su -c 'ls -l /lost+found'
  # quit privilege mode
  exit
  # with –s, sudo spawns a new shell running with root privileges
  sudo -s 
  ls -l /lost+found
  exit
  ```
  * Where to find documentation
  * man: displays the system manual
  ```bash
  man man
  # displays the man page for the passwd utility from section 1 of the system manual
  man passwd
  #  see the man page for the passwd file from section 5
  man 5 passwd
  ```  
  * apropos: searches for a keyword
  ```bash
  apropos who
  # the –k (keyword) option, provides the same output as apropos
  man -k who
  # the –k (keyword) option, provides the same output as apropos
  whatis who
  ```
  * info: displays information about utilities
  ```bash
  # The info utility displays more complete and up-to-date information on GNU utilities than does man.
  info who
  # The info utility displays more complete and up-to-date information on GNU utilities than does man.
  pinfo info  
  ```
  * The --help and -h option
  ```bash
  cat --help
  cat -h
  ls --help | less
  ```
  * The bash help command
  ```bash
  help
  ```
  * Getting help
    * Finding help locally
    ```bash
    ls /usr/share/doc
    cat /usr/share/doc/bzip2*/README
    ```
    * Using the Internet to get help
    * [The Linux Documentation Project](https://tldp.org/)
  * More about logging in and passwords
  ```bash
  pwgen
  ```
  * What to do if you cannot log in
  * Logging in remotely: terminal emulators, ssh, and dial-up connections
    * telnet is insecure, use ssh instead
  * Using virtual consoles
  * logging out
  ```bash
  exit
  ```
  * Changing your password
  ```bash
  # change current user's password
  passwd
  # change someone's password
  passwd username
  ```

---
---

# Linux utilities
*chapter 3*

* [Linux man pages](https://linux.die.net/man/)

## Objectives
* User and system management
  * Display information about users and the system
  * Communicate with other users
* file management
  * Create, copy, move, and remove folders and files
  * Use file commands to list files and display text files
  * Search, sort, print, and compare text files
  * Compress, decompress, and archive files
  * Locate files on the system
* Pipeline and special characters
  * String commands together using a pipeline
  * List special characters and methods of preventing the shell from interpreting these characters

## Topics

### User and system management
* Display information about the system

```bash
# echo - show a line of text
echo
# type - display information about command type
type

# uname - print system information
uname

# hostname - show or set the system's host name
hostname 

# uptime - show how long the system has been running
uptime

# date - print and set the system date and time
date

# free - display amount of free and used memory in the system
free

```

* Display information about users

```bash
# who - show who is logged in
who

# w - show who is logged on and what they are doing
w

# finger - show information about currently logged users
finger # not installed on ember.hpc.lab because of privacy and security concerns
# - show all users logged in host ember
finger @ember
# - show a specified user at ember
finger mike@ember
# - get information about mike
finger -q mike
# refer to the textbook for a quick comparison of these three commands

# last - displays information about the last logged-in users
last -n 5
```

* Communicate with other users

```bash
#  write - send a message to another user
# - synopsis: write user [ttyname]
# - Pressing CONTROL-D tells write to quit
# - press CONTROL- L or CONTROL- R to refresh the screen and remove the banner
write  mike # send mike a message

# mesg - Denies or Accepts Messages
# - allow other users to send you messages
mesg y # allow message
mesg n # block message

# sendmail - send an email
sendmail username
# receivemail - receive emails
receivemail
```


### file management

**List files and folders**

*In chapter 3, you work at your home folder(directory)*

```bash
# ls - list directory contents
ls

# create files
touch filename
cat > filename # Enter contents, press CTRL + D to complete typing

# change filename
mv oldname newname
# remove files
rm filename

# copy files
cp sourcefile destinationfile

# file - determine file type
file

# cat - concatenate files and print on the standard output
cat

# more - file perusal filter for sreen viewing
more

# less - provides more than more
less 

# grep - search lines matching a pattern
grep

# head - output the first part of files
head

# tail - output the last part of files
tail

# sort - sort lines of text files
sort

# uniq - report or omit repeated lines
uniq

# wc - print newline, word, and byte counts for each file
wc

# diff - compare files line by line
diff

# pipeline | process information step by step
sort somefile | head -4

ls | wc -w


# unix2dos - UNIX to DOS(Windows) text file format converter
unix2dos unixfile windowsfile

# dos2unix - DOS(Windows) to UNIX text file format converter
dos2unix

# unix2mac, mac2unix

# tr - translate or delete characters

# script - make typescript of terminal session
script
```

**Print files**

```bash
# print file on the default printer
lpr filename

# list printers
lpstat -p

# print file on printer named deskjet
lpr -P deskjet myfile1 myfile2

# check print queue
lpq

# remove a print job from the print queue and stop it from printing
lprm jobnumber

```

**Locate and search files**

```bash
# which - shows the full path of shell commands
which
# whereis - locate the binary, source, and manual page files for a command
whereis
# locate - find files by name (not installed on ember)
locate
# find - search for files in a directory hierarchy
find
```


**Compress, decompress, and archive files**

```bash
# bzip2 - a block-sorting file compressor
# compress myfile into myfile.bz2
bzip2 -v myfile

# compress myfile into myfile.bz2 and keep myfile
bzip2 -v -k bigfile

# bzcat, bunzip2 - decompress compressed files
bzcat myfile.bz2
bunzip2 bigfile.bz2

# gzip, gunzip and zcat
# zip, unzip

# tar - pack and unpack archives
# archive myfile and myfolder
tar -cvf myarchive.tar myfile myfolder
# list archive contents
tar -tvf myarchive.tar
# extract archive
tar -xvf myarchive.tar
```

### Pipeline and special characters
  * String commands together using a pipeline
  * List special characters and methods of preventing the shell from interpreting these characters


* Special characters
> & ; | * ? ' " ` [ ] ( ) $ < > { } # / \ ! ~

  * whitespace or blank
    * RETURN, ends a command line
    * SPACE, TAB separate tokens on the command line
  * to use special characters as regular characters
    * quote them with single quotation marks
    * escape them with backslash
  * The only way to quote the erase character (CONTROL-H), the line kill character (CONTROL-U), and other control characters (try CONTROL-M) is by preceding each with a CONTROL-V. Single quotation marks and backslashes do not work. 

```bash
echo 'the erase character CONTROL-U' # we can't complete the right quote
echo 'the erase character CONTROL-V CONTROL-U' | hexdump -C # 
```

## References

* [Send and receive Gmail from the Linux command line](https://opensource.com/article/21/7/gmail-linux-terminal)
* [Setting Your Erase, Kill, and Interrupt Characters](https://docstore.mik.ua/orelly/unix3/upt/ch05_08.htm)
* [Linux last Command](https://www.baeldung.com/linux/last-command)