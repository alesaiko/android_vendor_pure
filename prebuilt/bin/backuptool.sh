#!/sbin/sh

export C="/tmp/backupdir"
export S="/system"

# Scripts in $S/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Preserve $S/addon.d in /tmp/addon.d
preserve_addon_d()
{
	# Addon.d can be found missing due to a few reasons
	[ -d "$S/addon.d" ] || return 1

	# Create a new subdir in temp directory and place addon.d there
	[ -d "/tmp/addon.d" ] || mkdir -p /tmp/addon.d

	cp -a $S/addon.d/* /tmp/addon.d/
	chmod 755 /tmp/addon.d/*.sh
}

# Restore /tmp/addon.d to $S/addon.d
restore_addon_d()
{
	# Addon.d can be found missing due to a few reasons
	[ -d "/tmp/addon.d" ] || return 1

	# Create a new subdir in system directory and place addon.d there
	[ -d "$S/addon.d" ] || mkdir -p $S/addon.d

	cp -a /tmp/addon.d/* $S/addon.d/
	rm -rf /tmp/addon.d
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage()
{
	# Addon.d can be found missing due to a few reasons
	[ -d "/tmp/addon.d" ] || return 1

	# Execute every script within temporary addon.d directory
	for i in $(find /tmp/addon.d/ -name '*.sh' | sort -n); do $i $1; done
}

case "$1" in
backup)
	mkdir -p $C
	preserve_addon_d
	run_stage pre-backup
	run_stage backup
	run_stage post-backup
;;
restore)
	run_stage pre-restore
	run_stage restore
	run_stage post-restore
	restore_addon_d
	rm -rf $C
	sync
;;
*)
	echo "Usage: $0 { backup | restore }"
	exit 1
;;
esac

exit 0
