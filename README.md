# forge

Ho costruito diversi template:
- 9001 alpine
- 9002 arch
- 9003 debian
- 9004 devuan
- 9005 fedora
- 9006 manjaro
- 9007 opensuse
- 9008 ubuntu

che vengono usati per create le varie vm forge-distro.

I MAC address vanno associati agli indirizzi sul router, per il rilascio di ip statici.

Ogni template ha una installazione base che comprende openssh e quemu-guest agent, user artisan/evolution abilitato a supervisore.

con p4create distro creo forge-distro a partire da 201 come VMID, dovrei anche creare delle furnace-distro da 301 in poi, con MACADDRESS casuale.


