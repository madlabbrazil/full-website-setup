#!/bin/bash
sed -i "s/#ips/set \$phpfpmip $FLLWS_PHP5_6_PORT_9000_TCP_ADDR;/g" /etc/nginx/conf.d/php.loc
sed -i "s/#include/include conf.d\/php.loc;/g" /etc/nginx/conf.d/default.conf;