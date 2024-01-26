#!/bin/bash
#
# Manage the BT-SENSOR data capture
#
mkdir -p /home/pi/Project_Rasp/LOG
##Option to keep RAW recording
##mkdir -p /home/pi/Project_Rasp/RAW
mkdir -p /home/pi/Project_Rasp/REC
LOG=/home/pi/Project_Rasp/LOG/Session_$(date --utc +%Y%m%d%H%M%S).log

if test `ps e --noheading -C simple-static | wc -l` -ge 1 ; then
 echo there is another data capture running, exit the script
 echo $(date --utc +%Y%m%d-%k:%M:%S) there is another data capture running, exit the script  >> $LOG
 #PID=`ps e --noheading -C simple-static | awk '{print $1}'`
 PID=`pidof simple-static`
 echo $PID
 if [ "$1" == "-f" ]
 then
  echo "first stopping rec " $PID
  sudo kill -12 $PID
  sleep 1
  if [ -s ./recording.bin ]
  then
   echo "Post processing existing recording.bin file"
   printf "["
   while [ -s recording.bin ]
   do
    printf "▓"
    sleep 1
   done
   printf "] done!"
   echo  ""
   echo "-------------------------"
  fi
  echo "then killing simple_static " $PID
  sudo kill -9 $PID > /dev/null
 else
  exit 1
 fi
fi

echo $(date --utc +%Y%m%d-%k:%M:%S) startup BT_SENSOR data capture >> $LOG

if [ -s ./recording.bin ]
then 
 echo "Previous recording is not empty :  REC/Rec_after_BadExit.csv will be created "
else
 rm -f ./recording.bin
fi

sudo ./simple-static >> $LOG 2>&1 &

sleep 2

PIDROOT=`ps -ef | grep simple-static | grep sudo | awk '{print $2}'`
PID=`pidof simple-static`

if [ "$PID" == "" ] 
then
 echo data capture is not running, exit the script
 echo Please check logs for more details $LOG
 exit 1 
else
 #echo "data capture is running with pid "$PID" and "$PIDROOT 
 echo "data capture is now running !"
fi

if [ -s ./recording.bin ]
then
 sleep 1
 echo "Post processing existing recording.bin file"
 printf "["
 while [ -s recording.bin ]
  do
  printf "▓"
  sleep 1
 done
 printf "] done!"
 echo  ""
 echo "-------------------------"
fi

while true; do
        echo "-------------------------------------------------------"
        echo "------------------------- Start recording          [R] "
        echo "------------------------- Stop  recording          [S] "
        echo "------------------------- Exit  sensor management  [E] "
        echo "-------------------------------------------------------"
        echo "-------------------------------------------------------"
	read rec

        if [ "eR" == "e${rec}" ]
	then
		#echo "starting rec " $PID
		if [ -s recording.bin ]
		then
		 echo "Recording is already running - Wrong input"
		else	
		sudo kill -10 $PID
		echo Recording started at $(date --utc +%Y%m%d-%k:%M:%S) 
		while [ ! -s recording.bin ]
		do
		sleep 1 
		done
		fi
        fi

        if [ "eS" == "e${rec}" ]
	then    
		if [ -s recording.bin ]
		then
		 sudo kill -12 $PID
        	 echo "-------------------------"
		 echo Recording stopped at $(date --utc +%Y%m%d-%k:%M:%S) 
		 echo "Post processing recording.bin file"
		 printf "["
		 while [ -s recording.bin ]
		  do
		  printf "▓"
		  sleep 1
		 done
		 printf "] done!"
		 echo  ""
        	 echo "-------------------------"
		else
		 echo "Recording is not running!!!!!!"
		fi
        fi

        if [ "eE" == "e${rec}" ]
	then
		echo Session exited at $(date --utc +%Y%m%d-%k:%M:%S) 
 		echo Please check logs for more details $LOG
        	echo "-------------------------"
        	echo "-------------------------"
		if [ -s recording.bin ]
		then
		 sudo kill -12 $PID
		 echo Recording stopped at $(date --utc +%Y%m%d-%k:%M:%S) 
		 echo "Post processing recording.bin file"
		 printf "["
		 while [ -s recording.bin ]
		  do
		  printf "▓"
		  sleep 1
		 done
		 printf "] done!"
		 echo  ""
        	 echo "-------------------------"
		fi
        	echo "-------------------------"
        	echo "-------------------------"
		#echo "first killing " $PIDROOT
		kill -9 $PIDROOT > /dev/null 2>&1
		#echo "then killing " $PID 
		sudo kill -9 $PID > /dev/null 2>&1
		break
        fi
done

