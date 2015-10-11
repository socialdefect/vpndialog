Simple dialog based script that helps newbies and lazy people connect
to an openvpn server. You can use your own server configurations or
download free vpn configurations from VPNbook.com.


Dependencies:

Make sure you install these programs before running the script.

	* openvpn
	* wget
	* dialog
	* unzip


Installation:

There is no need to install the script for it can run from any directory.
If you want to install it here is how to do it:

	* Download the script using git
	* Copy it to a bin directory in your PATH
	* Make sure it is executable

Commands to do this:

	cd /usr/src
	git clone https://github.com/socialdefect/vpndialog.git
	cd vpndialog
	chmod +x vpndialog.sh
	ln -s `pwd`/vpndialog.git /usr/bin/vpndialog

	this way the script is linked from it's git directory so if
	you run "git pull" in that directory it will pull any updates
	into that directory so there is no need to copy the script again
	when pulling an updated version.

	If you don't like plain scripts in your bin directory you can use 
	SHC to wrap it in a C file and build a binary.

	Command example:

	shc -f vpndialog.sh

	Or run: "shc --help" to check out more advanced options.



Changelog:

	## v0.2 ##
		* Fixed all previous bugs
		* Included lots of improvements to the code
		* Included Config Restore feature
		* Included Network Connection Test
		* Included open config in filemanager function

TODO:
	## v0.3 ##
		* Include UI window for download progress
		* Include UI window for vpn login and status messages





##### By Arjan van Lent 2015, License GPLv3 ###########
