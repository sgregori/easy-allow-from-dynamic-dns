# easy-allow-from-dynamic-dns
Some scripts to allow access to webservers and tcp ports only per determinated IP.

Remember:
- Install dependencies:
	apt-get install dnsutils iptables

- Edit the script and setup the directories

- Write the domains to allow on /etc/easy-allow-from-dynamic-dns/allowed_domains

- Edit the nginx vhost file and add (see get_allowed_ips.nginx_example.conf):
```
location /private {

       include "/etc/easy-allow-from-dynamic-dns/allowed_ips_nginx.conf"
       deny all;

       }
```

- Run the script for first time and check the results.

- Setup a crontab:
        crontab -e
        * * * * * /etc/easy-allow-from-dynamic-dns/get_allowed_ips.sh &> /dev/null

