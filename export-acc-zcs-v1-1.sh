#!/bin/sh
clear
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# /* Variable for bold */
ibold="\033[1m""\n===> "
ebold="\033[0m"


echo -e $BRed"########################################################################"$Color_Off
echo -e $BRed"# Name          : export-acc-zcs.sh"$Color_Off
echo -e $BRed"# Version       : 0.1"$Color_Off
echo -e $BRed"# Date          : 2019-01-05"$Color_Off
echo -e $BRed"# Author        : VaVai"$Color_Off
echo -e $BRed"# Modifycation  : Vu Van Than - Linux System Engeneer Updated 05-01-2019"$Color_Off
echo -e $BRed"# Modifier      : SStrutt"$Color_Off
echo -e $BRed"# Compatibility : Centos7 LTS, Zimbra 8.7.x"$Color_Off
echo -e $BRed"# Purpose       : Export Zimbra Account & Password."$Color_Off
echo -e $BRed"# Exit Codes    : (if multiple errors, value is the addition of codes)"$Color_Off
echo -e $BRed"#   0 = success"$Color_Off
echo -e $BRed"#   1 = failure"$Color_Off
echo -e $BRed"########################################################################"$Color_Off

################ CHANGE LOG ############################################
# DATE       WHO WHAT WAS CHANGED
# ---------- --- ----------------------------
# 2011-10-23 VaVai Created script.
# 2019-01-05 Vu Van Than Updated script.
# 2019-01-05 Updated script to run on Centos 7 LTS, Zimbra 8.7.x
# 2019-01-05 Updated Only export the accounts which you enter from zcs-account-list.txt.
# 2019-01-05 Updated Backup Zimbra Account
# 2019-01-05 Updated Rename Zimbra Account & Close Account
#####################################################################
# TO DO !!
# Export Zimbra Account & Password
## ~~~~~!!!! SCRIPT RUNTIME !!!!!~~~~~ ##
# Best you don't change anything from here on, 
# ONLY EDIT IF YOU KNOW WHAT YOU ARE DOING

if [ "$USER" != "zimbra" ]
then
        echo -e $ibold"You need to be user zimbra to run this script..."$ebold
        exit
fi

# /* Parameter */
echo ""
echo -n "Enter Domain Name (ex : canifa.com) : " 
read NAMA_DOMAIN
echo -n "Enter path folder for exported account (ex : /home/thanvv/) : "
read FOLDER
echo -n "Enter path folder for a list of all account which you to export :"
read LIST_OF_ACCOUNTS

# /* Create export files and fill in domain names */
NAMA_FILE="$FOLDER/zcs-acc-add.zmp"
LDIF_FILE="$FOLDER/zcs-acc-mod.ldif"

rm -f $NAMA_FILE
rm -f $LDIF_FILE

touch $NAMA_FILE
touch $LDIF_FILE

echo "createDomain $NAMA_DOMAIN" > $NAMA_FILE

# /* Check the version of Zimbra used */
VERSION=`zmcontrol -v`;
ZCS_VER="/tmp/zcsver.txt"
# get Zimbra LDAP password
ZIMBRA_LDAP_PASSWORD=`zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3`

touch $ZCS_VER
echo $VERSION > $ZCS_VER

echo -e $ibold"Retrieve Zimbra User.............................."$ebold

grep "Release 8." $ZCS_VER
if [ $? = 0 ]; then
#USERS=`zmprov -l gaa`; # /* List of all accounts, uncomment if you want to list of all accounts */
USERS=`cat $LIST_OF_ACCOUNTS`  # /* Only export the accounts which you enter from zcs-account-list.txt */
LDAP_MASTER_URL=`zmlocalconfig -s ldap_master_url | cut -d ' ' -f3`
fi

echo -e $ibold"Processing account, please wait.............................."$ebold
# /* Proses insert account kedalam file hasil export */
for ACCOUNT in $USERS; do
NAME=`echo $ACCOUNT`;
DOMAIN=`echo $ACCOUNT | awk -F@ '{print $2}'`;
ACCOUNT=`echo $ACCOUNT | awk -F@ '{print $1}'`;
ACC=`echo $ACCOUNT | cut -d '.' -f1`

if [ $NAMA_DOMAIN == $DOMAIN ];
then
OBJECT="(&(objectClass=zimbraAccount)(mail=$NAME))"
dn=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep dn:`


displayName=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep displayName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`


givenName=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep givenName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

userPassword=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep userPassword: | cut -d ':' -f3 | sed 's/^ *//g' | sed 's/ *$//g'`

cn=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep cn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

initials=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep initials: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

sn=`ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep sn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

        if [ $ACC == "admin" ] || [ $ACC == "wiki" ] || [ $ACC == "galsync" ] || [ $ACC == "ham" ] || [ $ACC == "spam" ]; then
                echo "Skipping system account, $NAME..."
        else
                echo "createAccount $NAME passwordtemp displayName '$displayName' givenName '$givenName' sn '$sn' initials '$initials' zimbraPasswordMustChange FALSE" >> $NAMA_FILE

                echo "$dn
changetype: modify
replace: userPassword
userPassword:: $userPassword
" >> $LDIF_FILE
                echo "Adding account $NAME"
        fi
else
        echo "Skipping account $NAME"
fi

echo -e $ibold "Backup from your account $NAME on old the server" $ebold
ZMBOX=/opt/zimbra/bin/zmmailbox
DATE=`date +%Y-%m-%d_%H-%M`
$ZMBOX -z -m $NAME getRestURL "//?fmt=tgz" > $FOLDER/$NAME.$DATE.tar.gz

echo -e $ibold "Rename account to old_$NAME..." $ebold
# renaming old
zmprov renameAccount $NAME old_$NAME

echo -e $ibold "Close your old account old_$NAME..." $ebold
zmprov ma old_$NAME  zimbraAccountStatus closed

done
echo -e $ibold"All account has been exported sucessfully into $NAMA_FILE and $LDIF_FILE..."$ebold
