#!/bin/bash
#
# Title: ClamScan Daily
# Written by Joseph Bernadas (http://jbernadas.com)
# 05/31/2019 (dd/mm/yy)

LOGFILE="/var/log/clamav/clamscan-daily-$(date +'%Y-%m-%d-%H%M').log";
HOST="$(hostname --long)";
SERVERNAME="Ubuntu-Database server";
EMAIL_FROM="clamscan-daily@"$HOST"";
EMAIL_TO="<your@email.here>";
# You can add multiple directories separated by white space, i.e., "/var/www /var/lib/mysql /home/user"
DIRTOSCAN="/var/www";
# How many days of this log to keep
LOGONLYNUMDAYS=10;
MALWAREMSG="MALWARE found in ";
NOMALWAREMSG="No malware found in ";
EMAIL_MSG="IMMEDIATE ATTENTION REQUIRED!!! \nMalware found during today's ClamAV scan of ${SERVERNAME}, please see the attached log file for details.";

# Check for mail installation
type mail >/dev/null 2>&1 || { echo >&2 "I require mail but it's not installed. Aborting."; exit 1; };

# Look for info about last ClamAV database update
echo "Looking for latest ClamAV database update...";
echo "Found latest ClamAV database from:";
# Show the date of last database update from freshclam.log
tail -1 /var/log/clamav/freshclam.log;

TODAY=$(date +%u);

# Delete files older than LOGONLYNUMDAYS
find /var/log/clamav/ -type f -mtime +"$LOGONLYNUMDAYS" -name 'clamav-20*.log' -execdir rm -- '{}' \;

if [ "$TODAY" == "6" ];then
        echo "Started a full weekend scan.";
        # be nice to others while scanning the entire root
        nice -n5 clamscan -ri / --exclude-dir=/sys/ &>"$LOGFILE";

        # get the value of "Infected lines"
        MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

        # if the value is not equal to zero, send an email with the log file attached
        if [ "$MALWARE" -ne "0" ]; then
                echo -e "\n"$MALWAREMSG""$S" directory."
                echo -e "$EMAIL_MSG"|mail -a "$LOGFILE" -s "ClamAV: Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
        else
                echo -e "\n"$NOMALWAREMSG""$S" directory.";
        fi

else
        for S in ${DIRTOSCAN}; do
                DIRSIZE=$(du -sh "$S"  2>/dev/null|cut -f1);
                echo -e "\nStarted daily scan of "$S" directory in ${SERVERNAME}.\nAmount of data to be scanned is "$DIRSIZE".";
                clamscan -ri "$S" &>"$LOGFILE";

                # get the value of "Infected lines"
                MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

                # if the value is not equal to zero, send an email with the log file attached
                if [ "$MALWARE" -ne "0" ]; then
                        echo -e "\n"$MALWAREMSG""$S" directory."
                        echo -e "$EMAIL_MSG"|mail -a "$LOGFILE" -s "ClamAV: Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
                else
                        echo -e "\n"$NOMALWAREMSG""$S" directory.";
                fi

        done
fi

echo -e "\nClamScan Daily script has finished."
tail -1 -f /var/log/clamav/clamscan-daily-*.log

exit 0;
