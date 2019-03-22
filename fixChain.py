#!/usr/bin/python3'
import os

print("Applying all IP and INTERFACE values")
print("RCV ip: "+str(os.environ['EXTIP']))

##PHP chain
with open('/tftpboot/default.ipxe', 'r') as file:
    data = file.readlines()

for i in range(0,len(data)):
	if "chain" in data[i]:
		data[i] = "chain http://" + str(os.environ['EXTIP']) + "/fog/service/ipxe/boot.php##params"

with open('/tftpboot/default.ipxe', 'w') as file:
    file.writelines( data )


##PHP config TFTP/WEB
with open('/var/www/fog/lib/fog/config.class.php', 'r') as file:
    data = file.readlines()

for i in range(0,len(data)):
	#IP
	if "TFTP_HOST" in data[i]:
		data[i] = "	define('TFTP_HOST', \""  + str(os.environ['EXTIP']) + "\");\n"
	if "WOL_HOST" in data[i]:
		data[i] = "	define('WOL_HOST', \""  + str(os.environ['EXTIP']) + "\");\n"
	if "WEB_HOST" in data[i]:
		data[i] = "	define('WEB_HOST', \""  + str(os.environ['EXTIP']) + "\");\n"
	if "STORAGE_HOST" in data[i]:
		data[i] = "	define('STORAGE_HOST', \""  + str(os.environ['EXTIP']) + "\");\n"
	#INTERFACE
	if "MULTICASTINTERFACE" in data[i]:
		data[i] = "	define('MULTICASTINTERFACE', \"" + str(os.environ['ACTIVE_ETH']) +"\");\n"
	if "STORAGE_INTERFACE" in data[i]:
		data[i] = "	define('STORAGE_INTERFACE', \"" + str(os.environ['ACTIVE_ETH']) + "\");\n"
	if "WOL_INTERFACE" in data[i]:
		data[i] = "	define('WOL_INTERFACE', \"" + str(os.environ['ACTIVE_ETH']) + "\");\n"
	if "NFS_ETH_MONITOR" in data[i]:
		data[i] = "	define('NFS_ETH_MONITOR', \"" + str(os.environ['ACTIVE_ETH']) + "\");\n"
	if "UDPCAST_INTERFACE" in data[i]:
		data[i] = "	define('UDPCAST_INTERFACE', \"" + str(os.environ['ACTIVE_ETH']) + "\");\n"
with open('/var/www/fog/lib/fog/config.class.php', 'w') as file:
    file.writelines( data )

##TFTPD config
with open('/etc/default/tftpd-hpa', 'r') as file:
    data = file.readlines()

for i in range(0,len(data)):
	if "TFTP_ADDRESS" in data[i]:
		# data[i] = 'TFTP_ADDRESS="' + str(os.environ["EXTIP"]) + ':69"\n'
		data[i] = 'TFTP_ADDRESS="0.0.0.0:69"\n'

with open('/etc/default/tftpd-hpa', 'w') as file:
    file.writelines( data )

##.fogproject config for UPDATE/REINSTALL
with open('/opt/fog/.fogsettings', 'r') as file:
    data = file.readlines()

for i in range(0,len(data)):
    if "ipaddress" in data[i]:
        data[i] = "ipaddress=\'"  + str(os.environ['EXTIP']) + "\'\n"

with open('/opt/fog/.fogsettings', 'w+') as file:
    file.writelines( data )
