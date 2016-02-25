#!/system/bin/sh
(
export busybox="/data/data/com.galoula.LinuxInstall/bin/busybox"
# If $BINDS does not exist, then done of the others are set iether.
if $busybox [ -z "$BINDS" ]; then
	export DIST="debian squeeze"
	export FILESYSTEM=/flash/Linux.loop
	export MOUNTPOINT=/data/local/mnt/Linux
        export PREFIX=/data/local
	export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:$PATH:$PREFIX
	export TERM=linux
	export HOME=/root
	export USER=root
	export LOGNAME=root
	if $busybox [ ! 1$UID -eq 10 ]
	then
		export UID=0
	fi
	export SHELL="/bin/bash"
	export FS=ext4
	export BINDS="1"
	unset TMPDIR
fi
APKVersion="3.9"
APKBuild="2011/12/31"
LinuxChrootCreate="2012/05/23 19:56:01"
LinuxChrootName="linuxchroot"

doHelp()
{
	echo "-h		This help"
	echo "-v		Version"
	echo "-c		Config of $0"
	echo "mount		Mmount only Linux"
	echo "umount	Umount only Linux"
}

doConfig()
{
	echo "$0"
	echo "Mount Point:	$MOUNTPOINT"
	if $busybox [ -f $FILESYSTEM ]
	then
		echo "FileSystem is a LOOP file"
	else
		if $busybox [ -b $FILESYSTEM ]
		then
			echo "FileSystem is a BLOCK device"
		else
			if $busybox [ -b $FILESYSTEM ]
			then
				echo "FileSystem is a directory"
			fi
		fi
	fi
	echo "Scripts are :"
	echo "`$busybox which $LinuxChrootName`"
	echo "`$busybox which $LinuxChrootName.sh`"
}

doVersion()
{
	echo "$0 version $APKVersion build on $APKBuild"
	echo "Created on $LinuxChrootCreate"
}

createLinuxBoot() {
	if $busybox [ -d "$FILESYSTEM" ]
	then
		echo "I: Directory chroot !"
		if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT/proc")" ]; then
			# If the loop device is already mounted, we do nothing.
			echo "W: $DIST is already mounted. Entering chroot..."
		else
			echo "I: Mounting device for $DIST..."
			# Bind some Android dirs to the linux filesystem
			if $busybox [ $BINDS -eq 1 ]
			then
				# Create mtab
				echo > "${MOUNTPOINT}/etc/mtab"
				$busybox cat /proc/mounts > "${MOUNTPOINT}/etc/mtab"
	#			for i in `$busybox cat /proc/mounts | $busybox cut -d " " -f 2`
				for i in $( $busybox cat /proc/mounts | $busybox awk '{print $2}' )
				do
					$busybox mkdir -p "${MOUNTPOINT}/$i" 2> /dev/null
					$busybox mount -o bind "${i}" "${MOUNTPOINT}/${i}" 2> /dev/null
					#echo "${i}" >> "${MOUNTPOINT}/etc/mtab"
				done
				$busybox mount -t devpts devpts $(MOUNTPOINT)/dev/pts
				$busybox mount -t proc proc $(MOUNTPOINT)/proc
				$busybox mount -t sysfs sysfs $(MOUNTPOINT)/sys
			fi
		fi
	else
		if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
			# If the loop device is already mounted, we do nothing.
			echo "W: $DIST is already mounted. Entering chroot..."
		else
			echo "I: Mounting device for $DIST..."
			if $busybox [ ! -d $MOUNTPOINT ]; then
				# Create the mount point if it does not already exist
				$busybox mkdir -p $MOUNTPOINT 2> /dev/null
	
				if $busybox [ ! -d $MOUNTPOINT ]; then
					echo "F: It was not possible to create the missing mount location ($MOUNTPOINT)"
	
					return 0
				fi
			fi
			if $busybox [ -f "$FILESYSTEM" ]
			then
				# Android places loop devices in /dev/block/ instead of root /dev/
				# If there are none in /dev/ we create links between /dev/loopX and /dev/block/loopX so that losetup will work as it should.
				if $busybox [ ! -e /dev/block/loop0 ]; then
					i=0
					while [ $i -le 8 ]
					do
						$busybox mknod /dev/block/loop$i b 7 $i
						let i=1+$i
					done
				fi
		
				# Locate the current loop device file
				if $busybox [ ! -z "$($busybox losetup | $busybox grep "$FILESYSTEM")" ]; then
					# If the filesystem file is already attached to an loop device, we get the path to the device file.
					loblk=$($busybox losetup | $busybox grep "$FILESYSTEM" | $busybox cut -d ":" -f 1)
				else
					# If the filesystem file is not yet attached, we attach it.
					loblk=$($busybox losetup -f)
					$busybox losetup $loblk $FILESYSTEM 2> /dev/null
		
					# Make sure that the device was successfully attached to a loop device file
					if $busybox [ -z "$($busybox losetup | $busybox grep "$FILESYSTEM")" ]; then
						echo "F: It was not possible to attach the device to a loop device file"
		
						return 0
					fi
				fi
			fi
			if $busybox [ -b "$FILESYSTEM" ]
			then
				loblk=$FILESYSTEM
			fi
			# Mount the filesystem
			$busybox mount -t $FS $loblk $MOUNTPOINT 2> /dev/null
	
			if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
				# Bind some Android dirs to the linux filesystem
				if $busybox [ $BINDS -eq 1 ]
				then
					# Create mtab
					echo > "${MOUNTPOINT}/etc/mtab"
					$busybox cat /proc/mounts > "${MOUNTPOINT}/etc/mtab"
#					for i in `$busybox cat /proc/mounts | $busybox cut -d " " -f 2`
					for i in $( $busybox cat /proc/mounts | $busybox awk '{print $2}' )
					do
# /sdcard/Mon mount/Linux
						$busybox mkdir -p "${MOUNTPOINT}/$i" 2> /dev/null
						$busybox mount -o bind "${i}" "${MOUNTPOINT}/${i}" 2> /dev/null
						#echo "${i}" >> "${MOUNTPOINT}/etc/mtab"
					done
				fi
				#for i in $BINDS
				#do
				#	# Bind the dirs if they are not already binded
				#	if $busybox [ -z "$($busybox mount | $busybox grep "$MOUNTPOINT/$i ")" ]; then
				#		# Create any missing dirs in the mountpoint
				#		if $busybox [ ! -d $MOUNTPOINT/$i ]; then
				#			$busybox mkdir -p $MOUNTPOINT/$i
				#		fi
				#		$busybox mount -o bind $i $MOUNTPOINT$i
				#	fi
				#done
			else
				echo "F: It was not possible to mount $DIST at the specified location ($MOUNTPOINT)"
				return 0
			fi
		fi
	fi

	# FIX the "stdin: is not a tty" error in direct hadware case.
	if $busybox [ -z "$($busybox mount | $busybox grep "$MOUNTPOINT/dev/pts ")" ]; then
		$busybox mount -t devpts devpts $MOUNTPOINT/dev/pts
	fi

	# For the network.
	#sysctl -w net.ipv4.ip_forward=1
	echo 1 > /proc/sys/net/ipv4/ip_forward

	# Cleanup tmp folder.
	$busybox rm -rf $MOUNTPOINT/tmp/*

	if $busybox [ -f $MOUNTPOINT/etc/init.android/rc_mount.sh ]; then
		# Execute the mount init file, if it exists
		echo "I: Executing /etc/init.android/rc_mount.sh"
		$busybox chroot $MOUNTPOINT /etc/init.android/rc_mount.sh
	else
		echo "I: To run command when mounting Linux create executable file at /etc/init.android/rc_mount.sh"
	fi
	return 1
}

removeLinuxBoot() {
	if $busybox [ -d "$FILESYSTEM" ]
	then
		echo "I: Directory chroot !"
		# Unmount pts
		if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT/dev/pts ")" ]; then
			$busybox umount $MOUNTPOINT/dev/pts  2> /dev/null
		fi
		for i in $BINDS
		do
			# Unmount all binding dirs
			if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT/$i ")" ]; then
				$busybox umount $MOUNTPOINT/$i
			fi
		done
		for i in `$busybox cat /proc/mounts | $busybox tac | $busybox grep -v " $MOUNTPOINT " | $busybox grep "$MOUNTPOINT" | $busybox cut -d " " -f 2`;do umount $i 2> /dev/null;done	else
		if $busybox [ -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
			# If linux is not mounted, then do nothing.
			echo "W: $DIST is already unmounted"
		else
			echo "I: Unmounting $DIST..."

			if $busybox [ -f $MOUNTPOINT/etc/init.android/rc_unmount.sh ]; then
				echo "I: Executing /etc/init.android/rc_unmount.sh"
				# Execute the unmount init script, if it exist.
				$busybox chroot $MOUNTPOINT /etc/init.android/rc_unmount.sh
			else
				echo "I: To run command when unmounting Linux create executable file at /etc/init.android/rc_unmount.sh"
			fi

			sync

			# Make sure that we have an loop device file to use
			if $busybox [ -f "$FILESYSTEM" ]
			then
				if $busybox [ ! -z "$($busybox losetup | $busybox grep "$FILESYSTEM")" ]; then
					# Get the loop device file
					loblk=$($busybox losetup | $busybox grep "$FILESYSTEM" | $busybox cut -d ":" -f 1)
				else
					echo "E: Could not locate the loop device file. $DIST was not unmounted successfully"
				fi
			fi
			if $busybox [ -b "$FILESYSTEM" ]
			then
				loblk=$FILESYSTEM
			fi

			# Unmount pts
			if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT/dev/pts ")" ]; then
				$busybox umount $MOUNTPOINT/dev/pts
			fi

			for i in `$busybox cat /proc/mounts | $busybox tac | $busybox grep -v "$MOUNTPOINT " | $busybox grep "$MOUNTPOINT" | $busybox cut -d " " -f 2`;do umount $i 2> /dev/null;done
			for i in $BINDS
			do
				# Unmount all binding dirs
				if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT/$i ")" ]; then
					$busybox umount $MOUNTPOINT/$i
				fi
			done

			sync && sleep 1

			# Unmount the device
			$busybox umount $MOUNTPOINT 2> /dev/null && sleep 1

			# If the device could not be unmounted
			if $busybox [ ! -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
				echo "E: $DIST could not be unmounted. Trying to kill attached processes..."

				# Try to kill all processes holding the device
				for i in `$busybox grep "$MOUNTPOINT" /proc/*/maps 2> /dev/null | $busybox cut -d":" -f 1 | $busybox sort | $busybox uniq | $busybox cut -d "/" -f 3`; do kill $i 2> /dev/null; echo; done
				fuser -k -9 $MOUNTPOINT
				for i in `$busybox grep "$MOUNTPOINT" /proc/*/maps 2> /dev/null | $busybox cut -d":" -f 1 | $busybox sort | $busybox uniq | $busybox cut -d "/" -f 3`; do kill -9 $i 2> /dev/null; echo; done

				# Use umount with the -l option to take care of the rest
				$busybox umount -l $MOUNTPOINT 2> /dev/null && sleep 1
			fi

			# Make sure the device has been successfully unmounted
			if $busybox [ -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
				if $busybox [ -f "$FILESYSTEM" ]
				then
					# Try to detach the device from the loop device file
					$busybox losetup -d $loblk 2> /dev/null

					# Make sure that the device was successfully detached
					if $busybox [ -z "$($busybox losetup | $busybox grep "$FILESYSTEM")" ]; then
						echo "I: $DIST has been successfully unmounted"

					else
						echo "E: $DIST has been unmounted, but could not detach the loop device"
					fi
				fi
				if $busybox [ -b "$FILESYSTEM" ]
				then
					if $busybox [ -z "$($busybox mount | $busybox grep "$MOUNTPOINT ")" ]; then
						echo "I: $DIST has been successfully unmounted"

					else
						echo "E: $DIST has been unmounted, but could not detach the loop device"
					fi
				fi
			else
				echo "E: $DIST could not be unmounted successfully"
			fi

		fi
	fi
}

if $busybox [ -n "$1" ]
then
	if $busybox [ "-h" = "$1" ]
	then
		doHelp
		exit 0;
	else
		if $busybox [ "-v" = "$1" ]
		then
			doVersion
			exit 0;
		else
	    	if $busybox [ "-c" = "$1" ]
			then
				doConfig
				exit 0;
			else
				if $busybox [ "umount" = "$1" ]
				then
					removeLinuxBoot
					exit 0;
				else
					if $busybox [ "mount" = "$1" ]
					then
						createLinuxBoot
						exit 0;
					else
				    	echo "This option doesn't exist ! Try -h"
						exit 1;
					fi
				fi
			fi
		fi
	fi
fi
if $busybox [ "$1" = "unmount" ]; then
	removeLinuxBoot
else
	createLinuxBoot
	echo "I: Entering chroot..."
#	if $busybox [ $? -eq 1 ]; then
		if $busybox [ -f $MOUNTPOINT/etc/init.android/rc_enter.sh ]; then
			echo "I: Executing /etc/init.android/rc_enter.sh"
			$busybox chroot $MOUNTPOINT /etc/init.android/rc_enter.sh
		else
			echo "I: To run command when enterring Linux create executable file at /etc/init.android/rc_enter.sh"
		fi

		$busybox chroot $MOUNTPOINT /bin/bash -i
		RET=$?
		echo $RET TODO change for noexec tests !		
		if $busybox [ -f $MOUNTPOINT/etc/init.android/rc_leave.sh ]; then
			echo "I: Executing /etc/init.android/rc_leave.sh ..."
			$busybox chroot $MOUNTPOINT /etc/init.android/rc_leave.sh
		else
			echo "I: To run command when leaving Linux create executable file at /etc/init.android/rc_leave.sh"
		fi
		if $busybox [ -d "$FILESYSTEM" ]
		then
			echo "Q: Do you want to unmount binds on $DIST directory, or leave it as is ? Y will kill all process as required; any other key will leave services running."
		else
			echo "Q: Do you want to unmount the $DIST environment, or leave it as is ? Y will kill all process as required; any other key will leave services running."
		fi
		read REPLY
		if $busybox [ "y$REPLY" = "yy" ] || $busybox [ "y$REPLY" = "yY" ]; then
			removeLinuxBoot
		fi
#	else
#		echo "Crash"
#	fi
fi
)
