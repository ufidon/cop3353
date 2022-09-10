# Linux file system
*chapter 4*

* [Linux man pages](https://linux.die.net/man/)

# Objectives
* The hierarchical filesystem
  * directory and file
  * the working directory
  * home directory
* Pathnames
  * absolute pathnames
  * relative pathnames
* Working with directories
* Access control
  * access permissions
  * ACLs: Access Control Lists
* Links
  * hard links
  * symbolic links
  * dereferencing symbolic links


# Topics

## The hierarchical filesystem
* [directory and file](https://tldp.org/LDP/intro-linux/html/chap_03.html)
* [Filesystem Hierarchy Standard](https://www.pathname.com/fhs/)

```bash
# show the hierarchical filesystem
tree # explain important standard directories and files
```

* filenames - case sensitive

```bash
#  how to use spaces within filenames
touch 'my file'
#  filename extensions
touch image.jpg
file image.jpg # Linux file type is not determined by its extension
#  hidden filenames
touch .invisible
ls -a # show hidden files
```

* the working directory

```bash
# print working directory
pwd

```

* home directory

```bash
# go to home directory
cd
cd ~
cd ~someone
su # switch user

# startup files
ls .bash*
```


## Pathnames
* navigate filesystem tree

```bash
# absolute pathnames
ls /home/someone


# relative pathnames
ls ./afolder
ls ../../bfolder

# navigate filesystem tree
cd
```

## Working with directories
```bash
# create directories
mkdir dir1 dir2 dir3
mkdir folder{1..3} dir{a..b}

# create a directory without itermediate folders
mkdir -p "/home/$USER/hir1/hir2/hir3"

# remove empty directories
rmdir folder{1..3} dir{a..b}

# remove non-empty directories
touch dir1/afile

rmdir dir1 # failed
rm -i -r dir1

# move or rename a folder
mv dir2 folder2 # what happened to mv if folder2 exists or not exists
mv dir3 folder2

touch file{1..3}
mv file1 file2 file3 folder2

# cp a folder
cp -r folder2 folder4

```

## Access control
* [access permissions](https://linuxconfig.org/understanding-of-ls-command-with-a-long-listing-format-output-with-permission-bits)
* [chmod - change file permissions](https://www.computerhope.com/unix/uchmod.htm)

```bash
# show file permissions
ls -l # filetype:owner:group:other

# chmod - change file permissions
chmod

# setuid and setgid - DANGER!
# setuid
chmod u+s program
# setgid
chmod g+s program

# show directory access permission
# Execute permission is redefined for a directory: It means that you can cd into the directory and/or examine files that you have permission to read from in the directory. It has nothing to do with executing a file.
ls -ld dir
```

* [ACLs: Access Control Lists](https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-security-acls.html)
  * ACLs (Access Control Lists) provide finer-grained control over which users can access specific directories and files than do traditional permissions
  * ACLs can reduce performance
  * Not all utilities preserve ACLs

```bash
# getfacl - show acl
getfacl myfile myfolder

# When a file has an ACL, ls –l displays a plus sign (+) following the permissions, even if the ACL is empty:
ls -l myfile myfolder

# setfacl ––modify ugo:name:permissions file-list
# An access rule specifies access information for a single file or directory
setfacl -m u:someone:rwx myfolder

# The line in the output of getfacl that starts with mask specifies the effective rights mask.
# set the effective rights mask to read only
setfacl -m mask::r-- myfolder

# set default acl rules. A default ACL pertains to a directory only; 
# it specifies default access information (an ACL) for any file in the directory that is not given an explicit ACL.
# traditional Linux permissions take precedence over other ACL rules.
setfacl -d -m g:group1:r-x,g:group2:rwx dir

# Most utilities do not preserve ACLs
mv myfolder /tmp


# enable acl
# check acl on a partition
get partition-mount-path /etc/fstab

# enable acl on a partition by adding acl in its option list in /etc/fstab, then remount it or restart the machine
mount -v -o remount /home

```

## Links
A link is a pointer to a file.

* A hard link is a direct pointer to a file (the directory entry points to the inode)
* Hard links are becoming outdated, use soft links instead
* A hard link can't point to a directory, but a symbolic link can
* Hard links can't link files in different filesystems, while a symbolic link can point to any file
* A symbolic link can point to a nonexistent file
* Delete the last hard link, the linked-to file is deleted; delete a soft link just itself is gone

```bash
# create hard link
ln myfile a-hard-link

# An inode is the control structure for a file
# Use ls with the –i option to determine files are linked if they have the same inode number
ls -li
```

*  A soft (symbolic) link is an indirect pointer to a file (the directory entry contains the pathname of the pointed-to file—a pointer to the hard link to the file).

```bash
# create a soft (symbolic) link
ln -s myfile mylink

# Unlike a hard link, a symbolic link to a file does not have the same status information as the file itself.
ls -l # check the file size of the file and the link

# Symbolic links are literal and are not aware of directories.
# Use absolute pathnames instead of relaive pathnames with symbolic links
#  A link that points to a relative pathname assumes the relative pathname 
# is relative to the directory that the link was created in
touch ~/notexist # exists at home
ln -s notexist /tmp/linktonotexist

ls -l ~/notexist /tmp/linktonotexist

cat /tmp/linktonotexist # failed

# If you use cd to change to a directory that is represented by a symbolic link, 
# the pwd shell builtin lists the name of the symbolic link. 
# The pwd utility (/bin/pwd) lists the name of the linked-to directory, 
# not the link, regardless of how you got there. 
# You can also use the pwd builtin with the –P (physical) option to display the linked-to directory. 

mkdir ~/where
ln -s ~/where /tmp/attmp
cd
pwd 

cd /tmp/attmp
pwd # shell builtin pwd shows shows the name of the symbolic link

/bin/pwd # utility pwd shows linked-to directory
pwd -P

cd .. # ends up in the directory holding the symbolic link 

cd attmp
cd -P .. # get to the parent directory holding the linked-to directory

# Remove a link
rm alink
```

* dereferencing a symbolic link means to follow the link to the target file rather than work with the link itself
  * To no-dereference a symbolic link means to work with the link itself
  * Many utilities have dereference and no-dereference options, 
  * usually invoked by the –L (––dereference) option and the –P (––no-dereference) option, respectively. 
  * Some utilities, such as chgrp, cp, and ls, also have a partial dereference option that is usually invoked by –H. 
  * With a –H option, a utility dereferences files listed on the command line only, not files found by traversing the hierarchy of a directory listed on the command line.

```bash
# Most utilities default to no-dereference, although many do not have an explicit no-dereference option like ls
ls -l

#  the –L (––dereference) option to ls dereferences symbolic links
ls -lL

# Without a symbolic link as an argument to ls, the –H (partial dereference; this short option has no long version) option displays the same information as the –l option.
ls -lH

# With a symbolic link as an argument to ls, the –H option causes ls to dereference the symbolic link
ls -lH asoftlink

ls -lH *

# readlink - shows the absolute pathname of a file, dereferencing symbolic links when needed. 
# With he –f (––canonicalize) option, readlink follows nested symbolic links; all links except the last must exist.
ln -s myfile slink1
ln -s slink1 slink2
ln -s  slink2 slink3
readlink -f slink3

# Dereferencing symbolic links using chgrp - Change the group of each FILE to GROUP
ls -lR # before change group

# With the –R and –H options (when used with chgrp, –H does not work without –R), chgrp dereferences only symbolic links
# listed on the command line and those in directories listed on the command line. 
# It changes the group association of the files these links point to. 
# It does not dereference symbolic links it finds as it descends directory hierarchies, 
# nor does it change symbolic links themselves. 

chgrp -RH newgroup myfolder1 myfolder2
ls -lR # check the result

# With the –R and –L options (when used with chgrp, –L does not work without –R), chgrp dereferences all symbolic links:
#  those  listed on the command line and those it finds as it descends the directory hierarchy. 
# It does not change the symbolic links themselves.
ls -lR # before change group
chgrp -RL newgroup myfolder1 myfolder2
ls -lR # check the result

# With the –R and –P options (when used with chgrp, –P does not work without –R), 
# chgrp does not dereference symbolic links. 
# It does change the group of the symbolic link itself.
ls -lR # before change group
chgrp -RP newgroup myfolder1 myfolder2
ls -lR # check the result
```

## Disk space
```bash
# df - Show information about the file system on which each FILE resides, or all file systems by default.
df -h

# du - Summarize disk usage of the set of FILEs, recursively for directories.
du -h /tmp
du -hs /tmp
```

## References
* [Introduction to Linux: A Hands on Guide](https://tldp.org/LDP/intro-linux/html/index.html)