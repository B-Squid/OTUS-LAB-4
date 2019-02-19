#!/bin/bash

POLLING_INTERVAL="1"
i="0"
DATE_FORMAT_LONG='+%F:%H-%M-%S'
DATE_FORMAT_SHORT='+%F'
MASK_ID='[0-9]+$'
MASK_NAME='[0-9a-zA-Z]+$'

#####FUNCTIONS####
usageEcho () {
	sleep 1
	echo "---"
	sleep 1
	echo "USAGE:-->   $0 -id process_id | -name process_name"
	echo ""
}

curTime () {
        case "$1" in
        long)
                timestamp=$(date $DATE_FORMAT_LONG)
                echo $timestamp
        ;;
        short)
                timestamp=$(date $DATE_FORMAT_SHORT)
                echo $timestamp
        ;;  
        *)  
                exit 1
        esac
}

writeLog () {
        getvalShort=$(curTime short)
        getvalLong=$(curTime long)
        logFile="watchdog-$getvalShort"		 		                                       #everyday new file 

        if [[ -e $logFile ]]  
        then
                if [[ -f $logFile && -w $logFile ]]; then echo $getvalLong $1 >> $logFile; fi
        else
                echo "No logfile, create"
                touch $logFile

                if [[ $? -eq 0 && -f $logFile && -w $logFile ]]; then echo $(uname -a) >> $logFile ; echo $getvalLong $1 >> $logFile; fi
        fi
}

####END FUNCTIONS####

####MAIN####
trap 'echo -e "\nSIGHUP detected"; writeLog "Watchdog died, sorry"; exit 1' 1				#trap SIGHUP
trap 'echo -e "\nCtrl+C detected"; writeLog "Watchdog died, sorry"; exit 1' 2				#trap SIGINT
trap 'echo -e "\nSIGQUIT detected"; writeLog "Watchdog died, sorry"; exit 1' 3 				#trap SIGQUIT
trap 'echo -e "\nHa-ha, i am  still alive!!!(SIGTERM detected)"' 15					#trap SIGTERM

sleep 1
echo "Process watchdog v0.1"
usageEcho
unset res

if [ ! -n "$1" ]
then
	sleep 1
	echo "Empty args! Bye..."
	exit 1
fi

case "$1" in
-id) param="$2"
	A=$MASK_ID
	;;

-name) param="$2"
	A=$MASK_NAME
	;;
*)
	sleep 1
	echo "Wrong key, exit."
	usageEcho
	exit 1
	;;
esac



if [[ $2 =~ $A ]]
then
	echo "Watchdog successfully started" & writeLog "Watchdog successfully started"
	case "$2" in
	([0-9]*)
		if [[ -z $(ps -p $2 | sed -n 2p |tr -s ' ' |  cut -f 2 -d ' ') ]]
		then 
			echo "Process not found, exit"
			exit 1
		fi #never exists, by pid
	;;	
	([0-9a-zA-Z]*)
               	if ! pgrep $2 > /dev/null; then echo "Process not found, exit"; exit 1; fi   #never exists, by name
	;;
	*)
	;;	
	esac
	
        while :
        do
		if [[ $A == "$MASK_NAME"  ]]
		then
                       	res=$(pgrep $2)
		else 
			res=$2
			echo $res
		fi

                if [[ -n $res ]]
                then
                	resurrection=$(tr -d '\0' < /proc/$res/cmdline)
                        sleep $POLLING_INTERVAL                                         #process in memory, keep watching
                        echo "Process \"$2\" in memory"
                        continue
                else
                	echo "Process \"$2\" disappeared, restoring..." & writeLog "Process \"$2\" disappeared, restoring"
                        sleep $POLLING_INTERVAL                                         #grace period for process start
                        bash -c "${resurrection} &"                                     #init adopt child
                        continue                                                        #safety, for future     
                fi
        done
else
	echo "Wrong arg in param"
fi

####END MAIN####

