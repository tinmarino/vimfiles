use v5.26;
no strict;
no warnings;

use Cwd;            # Currernt Working directory

# Welcome
say "Interactive Perl Starting";

# BaSh
sub term(;$){
    my $arg = shift;
    my $res = qq[bash -i $arg]; 
    system ($res);}
sub bash(;$){
    my $arg = shift;
    my $res = qx[bash -i -c '$arg'];}


# Vim
sub vi(;$){system("vi " . shift)}


# ll
sub ll(;$){system("ls -l " . shift)}
sub ls(;$){
    my $arg = shift;
    my @files = qx[ls $arg];
    @res = ();
    for (@files){
        chomp $_;
        push @res, $_;
    }
    return @res;
}


# cd, pwd, p Path
sub cd(;$) {chdir shift}
sub pwd() {cwd}
sub p() {cd '..'}
sub pp() {p;p}
sub ppp() {pp;p}


# Simple aliases from busybox (remove vi and ls)
@simple_aliases = qw/
    acpid addgroup adduser adjtimex ar arp arping ash
    awk basename beep blkid brctl bunzip2 bzcat bzip2 cal cat
    catv chat chattr chgrp chmod chown chpasswd chpst chroot
    chrt chvt cksum clear cmp comm cp cpio crond crontab
    cryptpw cut date dc dd deallocvt delgroup deluser depmod
    devmem df dhcprelay diff dirname dmesg dnsd dnsdomainname
    dos2unix dpkg du dumpkmap dumpleases echo ed egrep eject
    env envdir envuidgid expand expr fakeidentd false fbset
    fbsplash fdflush fdformat fdisk fgrep find findfs flash_lock
    flash_unlock fold free freeramdisk fsck fsck.minix fsync
    ftpd ftpget ftpput fuser getopt getty grep gunzip gzip hd
    hdparm head hexdump hostid hostname httpd hush hwclock id
    ifconfig ifdown ifenslave ifplugd ifup inetd init inotifyd
    insmod install ionice ip ipaddr ipcalc ipcrm ipcs iplink
    iproute iprule iptunnel kbd_mode kill killall killall5 klogd
    last length less linux32 linux64 linuxrc ln loadfont
    loadkmap logger login logname logread losetup lpd lpq lpr
    lsattr lsmod lzmacat lzop lzopcat makemime man md5sum
    mdev mesg microcom mkdir mkdosfs mkfifo mkfs.minix mkfs.vfat
    mknod mkpasswd mkswap mktemp modprobe more mount mountpoint
    mt mv nameif nc netstat nice nmeter nohup nslookup od
    openvt passwd patch pgrep pidof ping ping6 pipe_progress
    pivot_root pkill popmaildir printenv printf ps pscan pwd
    raidautorun rdate rdev readlink readprofile realpath
    reformime renice reset resize rm rmdir rmmod route rpm
    rpm2cpio rtcwake run-parts runlevel runsv runsvdir rx script
    scriptreplay sed sendmail seq setarch setconsole setfont
    setkeycodes setlogcons setsid setuidgid sh sha1sum sha256sum
    sha512sum showkey slattach sleep softlimit sort split
    start-stop-daemon stat strings stty su sulogin sum sv
    svlogd swapoff swapon switch_root sync sysctl syslogd tac
    tail tar taskset tcpsvd tee telnet telnetd test tftp tftpd
    time timeout top touch tr traceroute true tty ttysize
    udhcpc udhcpd udpsvd umount uname uncompress unexpand uniq
    unix2dos unlzma unlzop unzip uptime usleep uudecode uuencode
    vconfig vlock volname watch watchdog wc wget which who
    whoami xargs yes zcat zcip
    /;
for (@simple_aliases) {
    my $str = 'sub ' . $_  . '(;$;$){';
    $str .= 'my $arg = shift;';
    $str .= 'my $res = qx[' . $_ . ' $arg ];';
    $str .= 'chomp $res;';
    $str .= 'return $res;}';
    say $str;
    eval $str; }
