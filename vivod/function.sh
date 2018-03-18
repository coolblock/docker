#!/bin/sh

function checkdat()
{
	local RET
	RET=0

	# for every dat file
	for file in "banlist.dat" "fee_estimates.dat" "governance.dat" "mncache.dat" "mnpayments.dat" "netfulfilled.dat" "peers.dat"
	do
		# if file exists in .vivocore and is not a symlink
		if [ -f /home/vivo/.vivocore/$file ] && [ ! -h /home/vivo/.vivocore/$file ]
		then
			# if file exists in /vivo
			if [ -f /vivo/$file ]
			then
				# if file in .vivocore is older
				if [ $(stat -c %Z /home/vivo/.vivocore/$file) -le $(stat -c %Z /vivo/$file) ]
				then
					# delete file in .vivocore
					rm /home/vivo/.vivocore/$file
				else
					# delete file in /vivo
					rm /vivo/$file
					mv /home/vivo/.vivocore/$file /vivo/
				fi
			else
				# move file from .vivocore to /vivo
				mv /home/vivo/.vivocore/$file /vivo/
			fi
		fi
		if [ -f /vivo/$file ] && [ ! -f /home/vivo/.vivocore/$file ]
		then
			ln -s /vivo/$file /home/vivo/.vivocore/$file
		fi
		#                                                          banlist.dat only created on demand
		if [ $RET = 0 ] && [ ! -f /home/vivo/.vivocore/$file ] && [ ! $file = "banlist.dat" ]
		then
			RET=1
		fi
	done

	return $RET
}

function stopcont()
{
	killall vivod &>/dev/null
	killall crond &>/dev/null

	while :
	do
		ps | grep vivod | grep -v grep &>/dev/null
		if [ $? -ne 0 ]
		then
			break
		fi
	done

	checkdat
	exit 1
}
