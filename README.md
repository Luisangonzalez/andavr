# andavr

### Export to https://code.google.com/archive/p/andavr/

Install Instructions (works for non rooted devices)



1. Install android terminal emulator from marketplace

2. copy local.tar.gz to sdcard

3. copy busybox to sdcard

4. start terminal emulator

5. cd to /data/data/jackpal.androidterm

6. cat /sdcard/busybox > busybox

7. chmod 777 ./busybox

8. ./busybox gzip -d /sdcard/local.tar.gz and wait a while

9. ./busybox tar -xvf /sdcard/local.tar

10 rm ./busybox

11. menu-key->preferences->Initial Command = export PATH=/data/data/jackpal.androidterm/local/bin:$PATH

12. Close all terminal windows and restart terminal emulator

13. Restart terminal emulator and type avr-gcc -v to check installation



What it gives you



1. avr-gcc

2. avrlibc

3. avrdude probably most adapters only work with rooted devices, have to specify avrdude.conf its in \data\data\jackpal.androidterm\local\etc. Micro USB connector to HOST adapter avilable on amazon/ebay

4. shell utilities type busybox to see list

5. make - you must specify shell e.g. make SHELL=sh

6. gcc arm toolchain for creating command line tools 



Usefull android programs



1. Textwarrior editor with syntax highlighting FREE

2. AVR Fuse Calculator FREE

3. C4droid easy to use C compiler includes gcc plugin cost 99p

4. AIDE excellent mini ide for creating java android apps, with syntax highlighting and auto completion FREE

5. Terminal IDE good Terminal emulator alternative fully loaded with good stuff FREE

6. ES File Explorer, file manager, ftp, dropbox, samba FREE


