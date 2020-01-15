# Configuration

## Centos
---
1. Prerequisites
* Install EPEL Packages `yum install epel-release`
* Install ntfs-3g and fuse packages to support NTFS drives `yum install ntfs-3g fuse -y`
* Format the new NTFS filestsystem to xfs `mkfs.xfs -f /dev/sda` 

1. Identifying Additional HDD 

Run `blkid` to verify if HDD is detected. On detection of HDD, follow the below steps to configure as XFS file system.
* Run `fdisk -l` to list the devices, partitions and volume groups
* [Scan your hard drive for Bad Sectors or Bad Blocks](https://www.linuxtechi.com/check-hard-drive-for-bad-sector-linux/)
1. Partitioning HDD (Optional and for Primary HDD)
* On identifying the device(HDD), say /dev/sda as the target device to partition, run `fdisk /dev/sda`
* These steps below are not for secondary HDD as partitioning will not utilize the entire space
* Option `m` to list the operations, Option `p` to print the current partitions
* Note the start and end block ids of the current partitions
* Option `d` to delete the current partitions, select the partition to delete `2`
* Option `n` to create new partition, select only `1` partition for the HDD, select default start and end block id, it should match the one printed above
* Option `t` to select the type of partition, followed by `8e` to select as Linux LVM 
* Format the new partition to xfs `mkfs.xfs -f /dev/sda1` as only one partition was created
* Mount the new partition to test `mount -t xfs /dev/sda1 /data`
* Make entry in `/etc/fstab` to make it permanent
* Verify the mounted partition by running `df -Th` to see free and used space

1. Securing Drive and adding Redundancy
* [Software RAID and LVM](https://wiki.archlinux.org/index.php/Software_RAID_and_LVM#Installation)
* For the partitions that are needed as Raid 1, use `fdsik /dev/sdb3`,Press ‘t’ to change the partition type.
* Press ‘fd’ to choose Linux Raid Auto.
* Install Raid 1 on `/dev/sdb3` and `/dev/sda1` using `mdadm --create /dev/data --level=1 --raid-devices=2 /dev/sdb3 /dev/sda1`
* [Encrypting Raid devices](https://linuxgazette.net/140/pfeiffer.html)

1. Volume Group Setup

Logical Volume Manager (LVM) is a software-based RAID-like system that lets you create "pools" of storage and add hard drive space to those pools as needed.
* [LVM Basic](https://opensource.com/business/16/9/linux-users-guide-lvm)
* [Create, expand, and encrypt storage pools](https://opensource.com/article/18/11/manage-storage-lvm)

1. Volume Group Lifecycle
* [Migrate Data from one LV to another](https://www.golinuxhub.com/2018/04/how-to-migrate-move-logical-volumes-and-volume-group-disk.html)
* Identify the current Physical Volume and Volume Group mapping `pvscan` or `pvs`
* List the partitions and volumes in the Volume Groups `vgdisplay centos-digital -v`
* Logical volume and device mapping `lvs -o+devices`
* List all devices and device mapping `lsscsi`
* Before Reducing logical volume, move to another drive
* Format /dev/sdb3 to a physical volume: `pvcreate /dev/sdb3`
* Give /dev/sdb3 to the volume group centos-digital: `vgextend centos-digital /dev/sdb3`
* Migrate our logical volume Users from /dev/sdb2 to /dev/sdb3, `pvmove -n Users /dev/sdb2 /dev/sdb3`
* Verify if the data is migrated `lsblk` 
* Reduce your logical volume to make place for your new partition `lvresize -L 25G /dev/centos-digital/home`
* Use fdisk to reduce the size of /dev/sdb2 to 80G as total for volume group centos-digital was 75G (yes, a little bit bigger as we used in lvresize!)
* Use fdisk to create a new LVM partition, /dev/sdb3, with the new available space (it will be around 400G).
* Check if the kernel could automatically detect the partition change. See if /proc/partition matches the new state (thus, /dev/sdb3 is visible). If not, you need to reboot. (Probably it will.)
* Make /dev/sdb2 to be as big again `pvresize /dev/sdb2`

