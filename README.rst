==============
ClamScan Daily
==============

A Bash script for running an automated ClamAV scan and emailing the scan results. The script uses the Freshclam database and runs a clamscan to check for trojans, viruses and malware on a specified directory. The scan will be performed once daily on any number of specified directories from Sunday to Friday, and do a full system scan on Saturdays. Also included are instructions on how to configure CRON and SSMTP.

Requirements
============

To use this you need to have the following installed in your Linux based system:

- ClamAV
- ssmtp
- heirloom-mailx or mailx 
- ClamAV-Freshclam 
- unrar (needed by ClamAV)

Setup
=====

First install ClamAV by either building it from source () or use your Linux package manager. Using your Linux distros package manager to install ClamAV is quick and easy, but one downside is you get an older version of its scanning engine. Building from source takes a more involved process, but I think it is better.

Installing ClamAV and ClamAV-Freshclam
--------------------------------------
To install ClamAV and ClamAV-Freshclam using your distros package manager, issue the below commands appropriate for your distro.
On Debian/Ubuntu:
::
  # apt-get update && apt-get install clamav clamav-Freshclam

On Centos:
::
  # yum install epel-release
  # yum install clamav clamav-update

On Debian/Ubuntu, start ClamAV virus database updater:
::
  # service clamav-freshclam start

Or you can also use the following on Debian/Ubuntu machines:
::
 # /etc/init.d/clamav-freshclam start

Invoking the above commands will run freshclam in daemon mode, meaning it will always be running in the background. To confirm it is running, issue the following:
::
  # ps -ef | grep fresh | grep clam
  clamav   16235     1  0 Jun05 ?        00:00:05 /usr/bin/freshclam -d --foreground=true
