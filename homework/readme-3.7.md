# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

```
в windows команда ipconfig
в линукс команда ifconfig(устаревшее) и ip

vagrant@vagrant:~$ ip -c -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64
eth1             DOWN
vagrant@vagrant:~$ ip -c -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP>
eth1             DOWN           08:00:27:1d:2f:01 <BROADCAST,MULTICAST>

```

2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

```
используется протокол LLDP (или аналог CDP)

lldpctl из пакета lldpd

или

vagrant@vagrant:~$ arp -an
? (10.0.2.3) at 52:54:00:12:35:03 [ether] on eth0
? (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0

vagrant@vagrant:~$ ip -c neighbour
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
```

3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

```
технология vlan

есть пакет vlan

пример конфига:
vagrant@vagrant:~$ cat /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto vlan1400
iface vlan1400 inet static
        address 192.168.1.1
        netmask 255.255.255.0
        vlan_raw_device eth0
```

4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

```
Типы агрегации: 
Mode-0(balance-rr), mode=1 (active-backup), mode=2 (balance-xor), mode=3 (broadcast), mode=4 (802.3ad), mode=5 (balance-tlb), mode=6 (balance-alb)



vagrant@vagrant:~$ cat /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto bond0
iface bond0 inet static
    address 192.168.1.150
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1 8.8.8.8
    dns-search domain.local
        slaves eth0 eth1
        bond_mode 0
        bond-miimon 100
        bond_downdelay 200
        bound_updelay 200

```

5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

```
в сети с маской /29 8 адресов, 6 хостов
из сети с маской /24 можно получить 32 подсети с маской /29

10.10.10.6
10.10.10.125
```

6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

```
100.64.0.0/26
```

7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

```
в windows: arp -a
в linux:
vagrant@vagrant:~$ arp -a
? (10.0.2.3) at 52:54:00:12:35:03 [ether] on eth0
_gateway (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0

Очистить:
vagrant@vagrant:~$ sudo ip -s n flush all

*** Round 1, deleting 1 entries ***
*** Flush is complete after 1 round ***

Удалить:
vagrant@vagrant:~$ sudo arp -d 10.0.2.3

```