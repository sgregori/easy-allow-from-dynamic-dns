#!/bin/bash

#
# Remember:
# - Install dependencies and add a crontab:
#   apt-get install dnsutils
#
# Setup a crontab:
#   crontab -e
#   * * * * * /etc/easy-allow-from-dynamic-dns/get_allowed_ips.sh &> /dev/null

CFG_DIR="/etc/easy-allow-from-dynamic-dns"
ALLOWED_DOMAINS_FILE=$CFG_DIR"/allowed_domains"
NGINX_OUTPUT_FILE=$CFG_DIR"/allowed_ips_nginx.conf"
IPTABLES_OUTPUT_FILE=$CFG_DIR"/allowed_iptables.sh"

mkdir -p "$CFG_DIR" &> /dev/null
chmod -R 777 "$CFG_DIR"
chown -R www-data:www-data "$CFG_DIR"
cp get_allowed_ips.sh "$CFG_DIR"/get_allowed_ips.sh &> /dev/null
chmod +x "$CFG_DIR"/get_allowed_ips.sh
touch "$CFG_DIR"/allowed_domains
echo " " > $NGINX_OUTPUT_FILE
echo " " > $IPTABLES_OUTPUT_FILE
chmod -R 777 "$CFG_DIR"
chown -R www-data:www-data "$CFG_DIR"

DATE=$(date --rfc-3339=seconds)

echo -e "\t# Generated at $DATE by script: $0" > ${NGINX_OUTPUT_FILE}

echo -e "\t# Generated at $DATE by script: $0" > ${IPTABLES_OUTPUT_FILE}

while read LINEA
do
  IP=$(echo ${LINEA} | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
  if [[ ! -z ${LINEA} ]];
  then
    if [[ ! -z ${IP} ]];
    then
      echo -e "\tallow ${IP};" >> ${NGINX_OUTPUT_FILE} && echo -e "\tiptables -A INPUT -p tcp -s $IP -j ACCEPT" >> ${IPTABLES_OUTPUT_FILE}
    else
      IP=$(dig +short ${LINEA} | head -n 1)
      [[ ! -z ${IP} ]] && echo -e "\tallow ${IP};\t\t# ${LINEA}" >> ${NGINX_OUTPUT_FILE} && echo -e "\tiptables -A INPUT -p tcp -s $IP -j ACCEPT" >> ${IPTABLES_OUTPUT_FILE}
    fi
  fi
done < <(cat ${ALLOWED_DOMAINS_FILE} | sort | uniq | sed '/^\s*$/d')

echo "# NGINX RULES:"
cat ${NGINX_OUTPUT_FILE}
echo " "
echo "Testing configuration and reloading..."
nginx -t && service nginx reload

# Complete the iptables rules 

#echo "# DROP ALL RULES" >> ${IPTABLES_OUTPUT_FILE}

echo " "
echo "# IPTABLES RULES:"
cat ${IPTABLES_OUTPUT_FILE}
echo " "
echo "Reloading iptables rules..."
sh ${IPTABLES_OUTPUT_FILE}
echo " "
echo " - DONE!!!"
