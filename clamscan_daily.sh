#!/bin/bash
#
# Title: ClamScan Daily
# Author: Joseph Bernadas (http://jbernadas.com)
# 05/31/2019 (dd/mm/yy)

LOGFILE="/var/log/clamav/clamscan-daily-$(date +'%Y-%m-%d-%H%M').log";
HOST="$(hostname --long)";
SERVERNAME="<servername-here>";
EMAIL_FROM="clamscan-daily@"$HOST"";
EMAIL_TO="<your@email.here>";
# You can add multiple directories separated by white space, i.e., "/var/www /var/lib/mysql /home/user"
DIRTOSCAN="/var/www";
# How many days of this log to keep
LOGONLYNUMDAYS=10;
# Change this to any number from 1-7 (1 is Monday, 2 is Tuesday...), representing the day of the week you want to perform a full-system-scan
FULLSYSTEMSCAN="7"; # Sunday
MALWAREMSG="MALWARE found in ";
NOMALWAREMSG="No malware found in ";
EMAIL_MSG="IMMEDIATE ATTENTION REQUIRED!!! \nMalware found during today's ClamAV scan of ${SERVERNAME}, please see the attached log file for details.";

# Check for mail installation
type mail >/dev/null 2>&1 || { echo >&2 "I require mail but it's not installed. Aborting."; exit 1; };

# Starting the ClamScan-Daily script
echo -e "Starting ClamScan-Daily in ${SERVERNAME}...\n";
echo "Downloading the latest ClamAV virus database:"
# Download the latest ClamAV virus database
sudo freshclam

TODAY=$(date +%u);

# Delete files older than LOGONLYNUMDAYS
find /var/log/clamav/ -type f -mtime +"$LOGONLYNUMDAYS" -name 'clamscan-daily-20*.log' -execdir rm -- '{}' \;

if [ "$TODAY" == "$FULLSYSTEMSCAN" ];then
        echo "Started a full weekend scan.";
        # be nice to others while scanning the entire root
        sudo nice -n5 clamscan -ri / --exclude-dir=/sys/ &>"$LOGFILE";

        # get the value of "Infected lines"
        MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

        # if the value is not equal to zero, send an email with the log file attached
        if [[ "$MALWARE" -ne "0" ]]; then
                echo -e "\n"$MALWAREMSG""$S" directory."
                echo -e "$EMAIL_MSG"|mail -a "$LOGFILE" -s "ClamAV: Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
        else
                echo -e "\n"$NOMALWAREMSG""$S" directory.";
        fi

else
        for S in ${DIRTOSCAN}; do                
                DIRSIZE=$(du -sh "$S"  2>/dev/null|cut -f1);
                echo -e "\nStarted daily scan of "$S" directory. Amount of data to be scanned is "$DIRSIZE".";
                sudo clamscan -ri "$S" &>"$LOGFILE";

                # get the value of "Infected lines"
                MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

                # if the value is not equal to zero, send an email with the log file attached
                if [[ "$MALWARE" -ne "0" ]]; then
                        echo -e "\n"$MALWAREMSG""$S" directory."
                        echo -e "$EMAIL_MSG"|mail -a "$LOGFILE" -s "ClamAV: Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
                else
                        echo -e "\n"$NOMALWAREMSG""$S" directory.";
                fi

        done
fi

echo -e "\nClamScan Daily script has finished."

exit 0;
