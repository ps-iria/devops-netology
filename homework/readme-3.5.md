# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

```
разреженные файлы являются специальным форматом представления, в котором часть цифровой последовательности заменена сведениями о ней
```

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

```
при жесткой ссылке все права и владельцы одинаковые, при изменении одного из файлов остальные получают аналогичные права. Это происходит потому что оба файлы указывают на один участок на диске.
```

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
```


    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

```
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x9046be1e

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

```
root@vagrant:/home/vagrant# sfdisk -d /dev/sdb | sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0xa187b8ea.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xa187b8ea

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

```
vagrant@vagrant:~$ sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
vagrant@vagrant:~$ sudo mdadm --detail /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Nov 23 04:45:25 2021
        Raid Level : raid1
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 23 04:45:36 2021
             State : clean
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : vagrant:0  (local to host vagrant)
              UUID : 974bc34b:219de19a:f8d2649f:29f31fa7
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
```
7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

```
vagrant@vagrant:~$ sudo mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
vagrant@vagrant:~$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Nov 23 04:47:58 2021
        Raid Level : raid0
        Array Size : 1042432 (1018.00 MiB 1067.45 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Nov 23 04:47:58 2021
             State : clean
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

            Layout : -unknown-
        Chunk Size : 512K

Consistency Policy : none

              Name : vagrant:1  (local to host vagrant)
              UUID : 96fa81b7:00f95f47:ef074e5c:1f34e3e6
            Events : 0

    Number   Major   Minor   RaidDevice State
       0       8       18        0      active sync   /dev/sdb2
       1       8       34        1      active sync   /dev/sdc2
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

```
vagrant@vagrant:~$ sudo pvcreate /dev/md0 /dev/md1
  Physical volume "/dev/md0" successfully created.
  Physical volume "/dev/md1" successfully created.
vagrant@vagrant:~$ sudo pvscan
  PV /dev/sda5   VG vgvagrant       lvm2 [<63.50 GiB / 0    free]
  PV /dev/md0                       lvm2 [<2.00 GiB]
  PV /dev/md1                       lvm2 [1018.00 MiB]
  Total: 3 [<66.49 GiB] / in use: 1 [<63.50 GiB] / in no VG: 2 [2.99 GiB]
```

9. Создайте общую volume-group на этих двух PV.

```
vagrant@vagrant:~$ sudo vgcreate md_vol_gr_1 /dev/md0 /dev/md1
  Volume group "md_vol_gr_1" successfully created
vagrant@vagrant:~$ sudo vgdisplay
  --- Volume group ---
  VG Name               vgvagrant
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <63.50 GiB
  PE Size               4.00 MiB
  Total PE              16255
  Alloc PE / Size       16255 / <63.50 GiB
  Free  PE / Size       0 / 0
  VG UUID               PaBfZ0-3I0c-iIdl-uXKt-JL4K-f4tT-kzfcyE

  --- Volume group ---
  VG Name               md_vol_gr_1
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               Ld1Jkv-ke4o-Y0cj-B4ef-kKKE-2Wwf-POI2tw
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```
vagrant@vagrant:~$ sudo lvcreate -L 100M -n LV_md1 md_vol_gr_1 /dev/md1
  Logical volume "LV_md1" created.
vagrant@vagrant:~$ sudo lvs
  LV     VG          Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LV_md1 md_vol_gr_1 -wi-a----- 100.00m
  root   vgvagrant   -wi-ao---- <62.54g
  swap_1 vgvagrant   -wi-ao---- 980.00m
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

```
vagrant@vagrant:~$ sudo mkfs.ext4 /dev/md_vol_gr_1/LV_md1
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

```
vagrant@vagrant:~$ sudo mount /dev/md_vol_gr_1/LV_md1 /tmp/new
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

```
vagrant@vagrant:~$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2021-11-23 05:56:31--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22474564 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                                    100%[=================================================================================================================>]  21.43M   639KB/s    in 34s

2021-11-23 05:57:05 (650 KB/s) - ‘/tmp/new/test.gz’ saved [22474564/22474564]
```

14. Прикрепите вывод `lsblk`.

```
vagrant@vagrant:~$ lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                        8:0    0   64G  0 disk
├─sda1                     8:1    0  512M  0 part  /boot/efi
├─sda2                     8:2    0    1K  0 part
└─sda5                     8:5    0 63.5G  0 part
  ├─vgvagrant-root       253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1     253:1    0  980M  0 lvm   [SWAP]
sdb                        8:16   0  2.5G  0 disk
├─sdb1                     8:17   0    2G  0 part
│ └─md0                    9:0    0    2G  0 raid1
└─sdb2                     8:18   0  511M  0 part
  └─md1                    9:1    0 1018M  0 raid0
    └─md_vol_gr_1-LV_md1 253:2    0  100M  0 lvm   /tmp/new
sdc                        8:32   0  2.5G  0 disk
├─sdc1                     8:33   0    2G  0 part
│ └─md0                    9:0    0    2G  0 raid1
└─sdc2                     8:34   0  511M  0 part
  └─md1                    9:1    0 1018M  0 raid0
    └─md_vol_gr_1-LV_md1 253:2    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла:

```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
```

```
vagrant@vagrant:~$ gzip -t /tmp/new/test.gz
vagrant@vagrant:~$ echo $?
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

```
vagrant@vagrant:~$ sudo pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 8.00%
  /dev/md1: Moved: 100.00%
```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

```
vagrant@vagrant:~$ sudo mdadm --fail /dev/md0 /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md0
```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```
[16233.142626] md/raid1:md0: Disk failure on sdc1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
```
```
vagrant@vagrant:~$ gzip -t /tmp/new/test.gz
vagrant@vagrant:~$ echo $?
0
```


20. Погасите тестовый хост, `vagrant destroy`.

```
C:\dev\vagrant>vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
> ```
 ---