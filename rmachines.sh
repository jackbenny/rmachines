#!/bin/bash

################################################################################
#                                                                              #
#  Copyright (C) 2011 Jack-Benny Persson <jake@cyberinfo.se>                   #
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program; if not, write to the Free Software                #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  #
#                                                                              #
################################################################################

### rMachines version 0.1 ###

### Add your machines to MACHINES. WEBPAGE is the output HTML file.
### The HTML file must to writable by the user running the script.
### If you add the -d option to the script, it will run over and over
### again and update the info every $SLEEP seconds. Add a & to run it
### in the background. For a cron job, don't add the -d option!
### RUSER is the remote user account. That user must have a valid SSH key.

MACHINES=("localhost host2 host3 host4")
WEBPAGE="test.html"
SLEEP=30
RUSER="jake"


##Sanity checks

if [ ! -w "$WEBPAGE" ]; then
        printf "You don't have write permission to ${WEBPAGE}\n";
        exit 192
fi

for i in ${MACHINES[*]}; do
        ssh -o PasswordAuthentication=no -l ${RUSER} $i uptime > /dev/null
        if [ "$?" -gt 0 ]; then
                printf "There was a problem accessing $i \n"
                exit 192
        fi
done


#Main routine (run checks and build HTML page)

Main()
{
        printf "<html><head><title>My rMachines</title></head>\n<body>\n\n" >\
         ${WEBPAGE}
        printf "<h1>\nMy rMachines\n</h1>\n" >> ${WEBPAGE}
        printf "" >> ${WEBPAGE}

        for i in ${MACHINES[*]}; do
                printf "<b>$i</b>" >> ${WEBPAGE}
                printf "\n<br>\n======================\n<br>\n" >> ${WEBPAGE}
                ssh -l ${RUSER} $i uptime >> ${WEBPAGE}
                printf "<br>\n" >> ${WEBPAGE}
                ssh -l ${RUSER} $i who >> ${WEBPAGE}
                printf "<p>\n" >> ${WEBPAGE}
        done

        printf "\n\n</body>\n" >> ${WEBPAGE}
        printf "</html>\n" >> ${WEBPAGE}
}


## Check if we want to run the script infinitive times (for background jobs)

if [[ "$1" = "-d" ]]; then
        while true
        do
                Main
        sleep ${SLEEP}
        done

## Run just once (for cron jobs)
else
        Main

fi

exit 0
