#!/bin/bash

source /usr/local/bin/common.sh

WORKERS_COUNT=${WORKERS_COUNT:-5}

# reset config
echo -en '{\n}' > /etc/sogo/sogo.conf

for conf in $(printenv| grep -i SOGO_ | cut -d= -f1);do
    update_conf "${conf:5}" "${!conf}"
done

if [[ -n ${MYSQL_SERVER//[[:blank:]]/} ]]; then
    source /usr/local/bin/mysql.sh
    wait_for_db
    init_db
fi

if [[ ${APACHE_ENABLED,,} = true ]]; then
    source /usr/local/bin/apache.sh
    configure_apache
fi

if [[ ${MEMCACHED_ENABLED,,} = true ]]; then
    /etc/init.d/memcached start
fi

log_info "Launching SOGo"
su -l sogo -s /bin/bash -c "/usr/sbin/sogod -WOWorkersCount ${WORKERS_COUNT} -WONoDetach YES -WOLogFile - -WOPidFile /tmp/sogo.pid"

