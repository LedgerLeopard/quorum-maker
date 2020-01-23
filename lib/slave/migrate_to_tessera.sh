#!/bin/bash

tessera_data_migration="java -jar /tessera/data-migration-cli.jar"

killall geth
killall constellation-node

mv qdata/#mNode#.mv.db qdata/#mNode#.mv.db.bak

sed -i "s|h2url|jdbc:h2:file:/home/node/qdata/#mNode#;AUTO_SERVER=TRUE|" qdata/tessera-migration.properties

${tessera_data_migration} -storetype dir -inputpath qdata/storage/payloads -dbuser -dbpass -outputfile qdata/#mNode# -exporttype JDBC -dbconfig qdata/tessera-migration.properties >> /dev/null 2>&1

if [ ! -f qdata/#mNode#.mv.db ]; then
    mv qdata/#mNode#.mv.db.bak qdata/#mNode#.mv.db
fi

LOCAL_NODE_IP="$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"
PORT=$(grep -o "CONSTELLATION_PORT=.*" /home/setup.conf | grep -o "[0-9]*")
MASTER_IP=$(grep -o "MASTER_IP=.*" /home/setup.conf | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
MASTER_PORT=$(grep -o "MAIN_NODEMANAGER_PORT=.*" /home/setup.conf | grep -o "[0-9]*")

sed -i "s/#localIp#/$LOCAL_NODE_IP/g" tessera-config.json
sed -i "s/#port#/$PORT/g" tessera-config.json
sed -i "s/#masterIp#/$MASTER_IP/g" tessera-config.json
sed -i "s/#masterPort#/$MASTER_PORT/g" tessera-config.json
sed -i "s/#nodeName#/#mNode#/g" tessera-config.json

mkdir -p qdata/tesseraLogs

echo "Completed Tessera migration. Restart node to complete take effect."