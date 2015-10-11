#!/bin/bash

###############
#   SU Test   #
###############

if [ "$UID" != '0' ] ; then
	echo 'You need superuser privileges to run openvpn.'
	echo 'Try executing using "sudo".'
	exit 1
fi

######################
#  Dependency Check  #
######################

for i in openvpn wget dialog unzip ; do
	if [ ! -f `which $i` ] ; then
		DEPS="$i 
		$DEPS"
		echo ; echo 'You need to install the following software
		before you can continue:'
		echo "$DEPS"
		exit 1
	fi
done

## Set the url variable for the vpnbook account details
URL="http://www.vpnbook.com/freevpn"

## Script version number
VPDVERSION='VPNdialog_v0.2'

## Wrapper for dialog to show the application name and version in dialog windows
SHOWVERSION="--backtitle "$VPDVERSION""


####################
#  Main Functions  #
####################

## Create config directory if none is found
NoConfig(){
	TITLE="Create Config"
	dialog $SHOWVERSION --title "$TITLE" --no-label "Exit" --yes-label "Get free vpnbook config" --yesno "Cannot find any configuration files.\
                please copy your vpn config to ~/.openvpn \
		or download free configurations from vpnbook." 0 0

		if [ "$?" = 1 ] ; then
			clear
			exit 1
		else
			GetConfig
		fi
}

## Backup and reset the vpndialog config directory
ResetConfig(){
	TITLE="Reset Config"
	dialog $SHOWVERSION --title "$TITLE" --yesno "Are You Sure? (Current config will be moved to ~/.openvpn.backup)." 0 0
	if [ "$?" = 0 ] ; then
		if [ -d ~/.openvpn.backup.old ] ; then
			rm -rf ~/.openvpn.backup.old
                        mv ~/.openvpn.backup ~/.openvpn.backup.old
			mv ~/.openvpn ~/.openvpn.backup
                fi

		if [ -d ~/.openvpn.backup ] ; then
                        mv ~/.openvpn.backup ~/.openvpn.backup.old
			mv ~/.openvpn ~/.openvpn.backup
                fi

		if [ -d ~/.openvpn ] ; then
			mv ~/.openvpn ~/.openvpn.backup &>/dev/null
		fi
		GetConfig
		Connect
	else
		clear
		exit 1
	fi
}

## Test Network connectivity and VPNbook public password
LoginFailed(){
	TITLE="Test Your Configuration"
	dialog $SHOWVERSION --title "$TITLE" --cancel-label "Test Network" --ok-label "Check VPNbook password" --extra-button --extra-label "Quit" --yesno "Test your network connection or view the VPNbook public account details." 0 0
	TEST="$?"
	if [ "$TEST" = 1 ] ; then
		dialog $SHOWVERSION --title "$TITLE" --infobox "Testing network connectivity.\
                        Please be patient....." 0 0 &
			KILLit="$$"
		ping -c 1 google.com &>/dev/null
		if [ "$?" != 0 ] ; then
			dialog $SHOWVERSION --title "$TITLE" --msgbox "Failed to connect to the internet.\
			Please check your connection" 0 0
			kill "$KILLit"
			LoginFailed
		else
			dialog $SHOWVERSION --title "$TITLE" --yes-label "Open config dir"  --extra-button --extra-label "Reset Config" --yesno "Your internet connection is up, check your vpn configuration in	~/.openvpn for possible errors." 0 0
			TEST="$?"
			if [ "$TEST" = 0 ] ; then
				if [ -f `which xdg-open` ] ; then
					xdg-open ~/.openvpn &>/dev/null
				else
					dialog $SHOWVERSION --title "$TITLE" --infobox "Cannot find xdg-open to launch the filemanager. Please install it if you like to use this feature."
				fi
			elif [ "$TEST" = 3 ] ; then
				ResetConfig
			fi
			LoginFailed
		fi

	elif [ "$TEST" = 3 ] ; then
		clear
		exit 1
	elif [ "$TEST" = 0 ] ; then
                if [ -f `which xdg-open` ] ; then
                        xdg-open "$URL" &>/dev/null
        		LoginFailed
        elif [ -f `which www-browser` ] ; then
                        www-browser "$URL" &>/dev/null
			LoginFailed
                else
                        dialog $SHOWVERSION --title "$TITLE" --msgbox "Cannot find a tool to launch your default browser.\
                        Please copy the following URL to your browser manually.\
                        ##################################\
                        http://www.vpnbook.com/freevpn\
                        ##################################" 0 0
                fi
                clear
                exit 0
	fi
}

## Download and extract VPNbook configuration files
GetConfig(){
	if [ ! -d ~/.openvpn/ ] ; then
		mkdir -p ~/.openvpn/
	fi
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

## Select what configuration file to use for a new vpn connection
SelectConfig(){
	TITLE="Select Configuration"
	dialog $SHOWVERSION --title "$TITLE" --no-items --menu 'Select a pofile to connect to:' "0" "0" "120" `cd ~/.openvpn/ ; ls *.ovpn` 2>/tmp/tmpfile
	if [ "$?" = 1 ] ; then
		clear
		exit 0
	fi

        CONFIGFILE=`cat /tmp/tmpfile`
        if [ -z "$CONFIGFILE" ] ; then
                NoConfig
        fi

	clear
	rm /tmp/tmpfile
}

## Create openvpn config directory and login.txt file which holds the current public password for vpnbook
MkConfig(){
        if [ ! -d ~/.openvpn ] ; then
                mkdir -p ~/.openvpn
                echo 'JE5Raphu' > ~/.openvpn/login.txt
                NoConfig
        fi
}

## Displays login info for vpnbook on connection
LoginInfo(){
        echo 'You will need a username and password to connect!'
        echo 'The following should work:'
        echo ; echo 'Login: vpnbook'
        echo "Password: `cat ~/.openvpn/login.txt`"
        echo ; echo ; echo 'If authentication fails visit:'
        echo "$URL" ; echo
        echo '#################################################'
}


## Reconnect, test connection or quit
Reconnect(){
	TITLE="Reconnect or Test"
	dialog $SHOWVERSION --title "$TITLE" --ok-label "Reconnect" --extra-button --extra-label "Test Connection" --cancel-label "Quit" --yesno "Connection terminated. What would you like to do now?:" 0 0
        ACTION=""$?""
        if [ "$ACTION" = 3 ] ; then
                LoginFailed
        elif [ "$ACTION" = 0 ] ; then
		Connect
        elif [ "$ACTION" = 1 ] ; then
                clear
                exit 1
        fi
}

## Run openvpn with the arguments given
Connect(){
	SelectConfig
        LoginInfo
        cd ~/.openvpn/
        COUNT=""
        openvpn "$CONFIGFILE"
        Reconnect
}

###############
#  Main loop  #
###############

TITLE="VPNdialog"
dialog $SHOWVERSION --title "$TITLE" --extra-button --extra-label "Reset Config" --yesno "Hit OK if you want to connect to a VPN or Hit Cancel to exit. If you experience any problems you can try to reset the configuration." 0 0
TEST="$?"
if [ "$TEST" = 0 ] ; then
	while true ; do
		MkConfig
		Connect
	done
elif [ "$TEST" = 3 ] ; then
	ResetConfig
	Connect
else
	clear
	exit 1
fi

clear
exit 0
