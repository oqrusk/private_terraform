#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y redis-tools mysql-client

echo 'mysql-connect: ' > index.html

mysql -h "${db_address}" \
    -P "${db_port}" \
    -D "${db_name}" \
    -u "${db_user}" \
    -p "${db_password}" \
    -e 'SELECT 1;' \
>> index.html

echo 'redis-connect: ' >> index.html
# redis-cli -h

nohup busybox httpd -f -p "${server_port}" &