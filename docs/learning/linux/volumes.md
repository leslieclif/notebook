# Why use LVM?
## Flexible Capacity
One benefit of using LVM is that you can create file systems that extend across multiple storage devices.
With LVM, you can aggregate multiple storage devices into a single logical volume.
## Easily Resize Storage While Online
LVM allows you to expand or shrink filesystems in real-time while the data remains online and fully accessible.
Without LVM you would have to reformat and repartition the underlying storage devices. Of course, you
would have to take the file system offline to perform that work. LVM eliminates this problem.
## Online Data Relocation
LVM also allows you to easily migrate data from one storage device to another while online. For example, if
you want to deploy newer, faster, or more resilient storage, you can move your existing data from the current
storage devices to the new ones while your system is active.
## Convenient Device Naming
Instead of using abstract disk numbers, you can use human-readable device names of your choosing.
Instead of wondering what data is on /dev/sdb, you can name your data with a descriptive name.
## Disk Striping
With LVM, you can stripe data across two or more disks. This can dramatically increase throughput by
allowing your system to read data in parallel.
## Data Redundancy / Data Mirroring
If you want to increase fault tolerance and reliability, use LVM to mirror your data so that you always have
more than one copy of your data. Using LVM mirroring prevents single points of failure. If one storage device
fails, your data can be accessed via another storage device. You can then fix or replace the failed storage
device to restore your mirror, without downtime.
## Snapshots
LVM gives you the ability to create point-in-time snapshots of your filesystems. This can be perfect for when
you need consistent backups. For example, you could pause writes to a database, take a snapshot of the
logical volume where the database data resides, then resume writes to the database. That way you ensure
your data is in a known-good state when you perform the backup of the snapshot.

# Layers of Abstraction in LVM
- The logical volume manager introduces extra layers of abstraction between the storage
devices and the file systems placed on those storage devices.
- The first layer of abstraction is physical volumes. These are storage devices that are used by LVM. The name
is a bit of a legacy name. To be clear, these storage devices do not have to be physical. They just have to be
made available to the Linux operating system. In other words, as long as Linux sees the device as a block
storage device, it can be used as a physical volume (PV). Physical hard drives, iSCSI devices, SAN disks, and
so on can be PVs. You can allocate an entire storage device as a PV or you can partition a storage device
and use just that one partition as a PV.
- The next layer of abstraction is the Volume Group. A volume group is made up of one or more PVs. You can
think of a volume group as a pool of storage. If you want to increase the size of the pool, you simply add
more PVs. Keep in mind that you can have different types of storage in the same volume group if you want.
For example, you could have some PVs that are backed by hard drives and other PVs that are backed by san
disks.
- The next layer of abstraction is the Logical Volume layer. Logical Volumes are created from a volume group.
File systems are created on Logical Volumes. Without LVM you would create a file system on a disk partition,
but with LVM you create a file system on a logical volume. As long as there is free space in the Volume
Group, logical volumes can be extended. You can also shrink logical volumes to reclaim unused space if you
want, but typically you'll find yourself extending logical volumes.

# Logical Volume Creation Process
At a high level, the process for creating a logical volume is this:
1. Create one or more physical volumes.
2. Create a volume group from those one or more physical volumes.
3. Finally, you can create one or more logical volumes from the volume group.
## Creating Physical Volumes
```BASH
# Verify which devices are used
su -
lvmdiskscan                     # Shows all the storage devices that have the ability to be used with LVM.
lsblk -p                        # Shows the partitions
df -h                           # Display sizes in a human readable format.
# Once verified which devices are not used
# Create the physical volumes
pvcreate /dev/sdb               # initializes the disk for use by the logical volume manager.
pvs                             # list of pvs
```
## Creating Volume Groups
```BASH
vgcreate vg_app /dev/sdb        # Volume group naming convention of "vg_".
vgs                             # view the volume groups
# It shows that we have 1 physical volume.
# The size of the volume group is 50GB and we have 50GB free in the volume group. 
# If we look at our pvs with the pvs command, we'll now see what VG our PV belongs to.
```
## Creating Logical Volumes
```BASH
lvcreate -L 20G -n lv_data vg_app   # Logical Volume naming convention of "lv_".
# Note captial L is to give human readable volume size
lvs                                 # view logical volumes
lvdisplay                           # Also to view lv, but it provides different output. 
# For example, notice the LV Path: ​ /dev/vg_app/lv_data​ 
# It's easy to tell that the ​ lv_data​ logical volume belongs to the vg_app​ volume group.
```
## Creating File Systems
- Now that we have a logical volume, we can treat it like we would a normal disk partition. 
- So, let's put a file system on our logical volume and mount it.
```BASH
mkfs -t ext4 /dev/vg_app/lv_data
mkdir /data
mount /dev/vg_app/lv_data /data
df -h /data
```
## Creating Multiple Logical Volumes in Volume Groups 
```BASH
lvcreate -L 5G -n lv_app vg_app
# Now you can see we have two logical volumes in vg_app
lvs
# We can put a file system on this logical volume and mount it.
mkfs -t ext4
/dev/vg_app/lv_app
mkdir /app
# Add Logical Volumes in the ​/etc/fstab​ so that it gets mounted at boot time.
# vi /etc/fstab
/dev/vg_app/lv_app /app ext4 defaults 0 0   # Save and quit
mount /app
df -h /app
df -h   
# You also access your logical volume through the device mapper path as shown in the df output. 
# For example, ​ /dev/vg_app/lv_app​ can be accessed via ​ /dev/mapper/vg_app-lv_app​ .
ls -l /dev/vg_app/lv_app
ls -l /dev/mapper/vg_app-lv_app
```
## Logical Extents and Physical Extents
There is yet another layer of abstraction that we haven't talked about. Well, two layers of abstraction, really.
Each of our LVs is actually divided up into LEs, which stands for logical extents. Or if we look at it from the
other direction, a collection of Logical Extents makes up a Logical Volume. This is how LVM allows us to
expand or shrink a logical volume -- the logical volume manager just changes the number of underlying
Logical Extents for the logical volume.
```BASH
lvdisplay -m            # Show a map of the logical volume.
# This map view tells us that the logical extents for the ​lv_app​ LV resize on the ​/dev/sdb​ disk. 
# Like an LV is divided into LE, a PV is divided into PE, physical extents. 
# There is a one-to-one mapping of LEs to PEs.
pvdisplay -m            # Shows a map from the view of the disk
```
## Create Logical Volumes using percentage
```BASH
lvcreate -l 100%FREE -n lv_logs vg_app
# Note small l is used with % or passing free extents 
# We can squeeze every possible bit of space out of your volume group and put it into a logical volume.
```
## Extending Volume Groups
- Let's say that the ​lv_data​ logical volume is getting full and we need to extend it.
-  If we look at our volume group, we'll see we've already allocated all our space to the existing logical volumes.
```BASH
vgs                 # Output shows VFREE = 0
# In this case, we need to extend the volume group itself 
# before we can extend the logical volume within that volume group.
lvmdiskscan         # Shows sdc is free
pvcreate /dev/sdc
vgextend vg_app /dev/sdc    # add this PV to our VG
vgs                 # Output shows VFREE = 50G
pvs                 # We have one pv that is complete full and one that is completely free.
#  Before we extend our logical volume into this free space, 
# let's look at the space from the file system level.
df -h /data
```
## Extending Logical Volumes
- Now, let's use the lvextend command to add 5GB of space to that logical volume. 
- In addition to increasing the size of the logical volume, we also need to grow the file system on that logical volume to fill up this new space. 
- That's what the ​ -r​ option is for.
```BASH
lvextend -L +5G -r /dev/vg_app/lv_data
df -h /data             # Shows filesystem has increased by 5G

# If you forget to use the ​-r​ option to lvextend to perform the resize, you'll have to do that after the fact.
lvextend -L +5G /dev/vg_app/lv_data
lvs                     # lv size has increased
df -h /data             # The file system is still the same size, and there is no 5G increase
# To fix this you'll have to use a resize tool for the specific filesystem you're working with. 
# For ext file systems, that tool is ​resize2fs​. 
# We give it the path the the underlying device, which is a logical volume in our case.
resize2fs /dev/vg_app/lv_data
df -h /data             # Shows filesystem has increased by 5G
lvdisplay -m /dev/vg_app/lv_data
# We see that some of the extents live on ​/dev/sdb​ while other extents live on ​/dev/sdc​ .
```
## Creating Mirrored Logical Volumes
- Mirrored logical volume will ensure that an exact copy of the data will be stored on two different storage devices.
```BASH
lvmdiskscan             # We have two more disks that we can use sdd and sde.
pvcreate /dev/sdd /dev/sde
vgcreate vg_safe /dev/sdd /dev/sde
lvcreate -m 1 -L 5G -n lv_secrets vg_safe
lvs                     # Copy%Sync column indicates if the mirror is synced.
# When it finished syncing the data, it would be at 100%.
lvs -a                  # The logical volume we created is actually RAID 1. So a mirror and raid 1 are the same thing.
# Let's create a file system on that logical volume and mount it.
mkfs -t ext4 /dev/vg_safe/lv_secrets
mkdir /secrets
mount /dev/vg_safe/lv_secrets /secrets
df -h /secrets
# So we write to ​ /dev/vg_safe/lv_secrets​ and let the logical volume manager handle the mirroring. 
# We just use this file system like any other.
```
## Deleting Logical Volumes, Volume Groups, and Physical Volumes
```BASH
# unmount the file system that is mounted inside logical volumes.
umount /secrets
# we can remove the underlying logical volume.
lvremove /dev/vg_safe/lv_secrets
# If you want to remove a pv from a vg, use the vgreduce command.
vgs
vgreduce vg_safe /dev/sde
pvs
pvremove /dev/sde
# Let's finish destroying the ​ vg_safe​ volume group with ​ vgremove​ .
vgremove vg_safe
vgs
pvs
pvremove /dev/sdd
```
## Migrating Data While Online
Early I mentioned how easy it is to move data from one storage device to another with LVM. Let's say that
the storage device attached to our system at ​`/dev/sde`​ is faster and has more space. Let's say we want to
move the data that currently resides on ​`/dev/sdb​` to that new disk. To do that, we'll just add ​`/dev/sde`​ to
the volume group and migrate the data over.
```BASH
# we ​pvcreate​ the device.
pvcreate /dev/sde
# Now we add it to the volume group.
vgextend vg_app /dev/sde
pvs
# Finally, we use the ​pvmove​ command to move all the data from ​/dev/sdb​ to ​/dev/sde​
pvmove /dev/sdb /dev/sde
```
Once the ​ pvmove​ command is complete, all the data the used to live on ​ /dev/sdb​ now lives on ​ /dev/sde​ .
And the whole time this was happening, any logical volumes and file systems that where on ​ /dev/sdb
remained online and available throughout this entire process. There's no need to take an outage for this
process.
```BASH
pvs                 # Now ​/dev/sdb​ is unused
pvdisplay /dev/sdb  # We see that "Allocated PE" is zero.
# Now that we're done with this disk we can remove it from the volume group with ​vgreduce​
vgreduce vg_app /dev/sdb
pvremove /dev/sdb
pvs
```