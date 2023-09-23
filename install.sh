#!/bin/bash

###############################################################
#                                                             #
#                      HotelStatistics                        #
#                                                             #
# A simple bash script to import ddl and dml of our project   #
#                                                             #
# Authors: Gabriele Biscetti, Simone Caruso                   #
#                                                             #
###############################################################

clear
echo -E '
 _   _       _       _   ____  _        _   _     _   _          
| | | | ___ | |_ ___| | / ___|| |_ __ _| |_(_)___| |_(_) ___ ___ 
| |_| |/ _ \| __/ _ \ | \___ \| __/ _` | __| / __| __| |/ __/ __|
|  _  | (_) | ||  __/ |  ___) | || (_| | |_| \__ \ |_| | (__\__ \
|_| |_|\___/ \__\___|_| |____/ \__\__,_|\__|_|___/\__|_|\___|___/
'

# Chech if mysql is installed 
which mysql  > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n MariaDB or MySQL is not installed\n\n"
  exit 1 
fi

echo -ne "Import script to load all SQL files \n\n"
read -p 'Username : ' uservar
read -sp 'Password : ' passvar
echo -ne "\n\n"


mysql --user=$uservar --password=$passvar  < schema.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Schema import FAILED\n\n"
  exit 1 
fi

mysql --user=$uservar --password=$passvar  < views.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Views import FAILED\n\n"
  exit 1 
fi

mysql --user=$uservar --password=$passvar  < procedures.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Stored procedures import FAILED\n\n"
  exit 1 
fi

mysql --user=$uservar --password=$passvar  < cursors.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Cursors import FAILED\n\n"
  exit 1 
fi

mysql --user=$uservar --password=$passvar  < triggers.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Triggers import FAILED\n\n"
  exit 1 
fi

mysql --user=$uservar --password=$passvar  < data.sql > /dev/null 2>&1

if [ $? != 0 ]
then
  echo -ne "\n Data import FAILED\n\n"
  exit 1 
fi

echo -ne "Import COMPLETED\n\n"
