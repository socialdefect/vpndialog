#!/bin/bash

NoConfig(){
	dialog --no-label "Exit" --yes-label "Get free vpnbook config" --yesno "Cannot find any configuration files.\
                please copy your vpn config to ~/.openvpn \
		or download free configurations from vpnbook." 0 0

		if [ $? = 1 ] ; then
			clear
			exit 1
		else
			GetConfig
		fi
}

LoginFailed(){
	URL="http://www.vpnbook.com/freevpn"
	if [ -f `which xdg-open` ] ; then
		xdg-open "$URL"
	elif [ -f `which www-browser` ] ; then
		www-browser "$URL"
	else
		dialog --msgbox "Cannot find a tool to launch your default browser.\
		Please copy the following URL to your browser manually.\
		##################################\
		  http://www.vpnbook.com/freevpn\
		##################################" 0 0
	fi
	clear
	exit $?
}

GetConfig(){
	cd ~/.openvpn/
	for i in Euro1 Euro2 US1 US2 CA1 DE1; do
		echo 'Need to download the configuration files'
		echo 'This will take a minute, please be patient.'
		echo '############################################'
		echo
		wget -c http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-$i.zip
		echo ; echo '######### Extracting config from archives ######' ; echo
		unzip VPNBook.com-OpenVPN-$i.zip
		echo '######### Deleting archives ######' ; echo
		rm -v VPNBook.com-OpenVPN-$i.zip
		echo
	done
}

SelectConfig(){
	dialog --no-items --menu 'Select a pofile to connect to:' "0" "0" "120" `cd ~/.openvpn/ ; ls *.ovpn` 2>/tmp/tmpfile
	if [ $? = 1 ] ; then
		clear
		exit 0
	fi

        CONFIGFILE=`cat /tmp/tmpfile`
        if [ -e "$CONFIGFILE" ] ; then
                NoConfig
        fi

	clear
	rm /tmp/tmpfile
}

dialog --yesno "Do you want to connect to a VPN?" 0 0
if [ $? = 0 ] ; then

	if [ ! -d ~/.openvpn ] ; then
		mkdir -p ~/.openvpn
		echo 'JE5Raphu' > ~/.openvpn/login.txt
		NoConfig
	fi


	SelectConfig
	echo 'You will need a username and password to connect!'
	echo 'The following should work:'
	echo ; echo 'Login: vpnbook'
	echo "Password: `cat .openvpn/login.txt`"
	echo ; echo ; echo 'If authentication fails visit:'
	echo "$URL" ; echo ; sleep 2
	echo '#################################################'

	cd ~/.openvpn/
	COUNT=""
	openvpn $CONFIGFILE
	while [ $? != 0 ] ; do
		if [ $COUNT = 1 ] ; then
			LoginFailed
		else
			openvpn $CONFIGFILE
			COUNT=1
		fi
	done
else
	clear
	exit 0
fi
