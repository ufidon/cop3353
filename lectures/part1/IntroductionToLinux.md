

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

# References
* [How to send jobs to background without stopping them?](https://serverfault.com/questions/41959/how-to-send-jobs-to-background-without-stopping-them)