#!/bin/bash

tessera_data_migration="java -jar /tessera/data-migration-cli.jar"

killall geth
killall constellation-node

mv /#mNode#/node/qdata/#mNode#.mv.db /#mNode#/node/qdata/#mNode#.mv.db.bak

sed -i "s|h2url|jdbc:h2:file:/#mNode#/node/qdata/#mNode#;AUTO_SERVER=TRUE|" node/tessera-migration.properties

${tessera_data_migration} -storetype dir -inputpath /#mNode#/node/qdata/storage/payloads -dbuser -dbpass -outputfile /#mNode#/node/qdata/#mNode# -exporttype JDBC -dbconfig node/tessera-migration.properties >> /dev/null 2>&1

if [ ! -f /#mNode#/node/qdata/#mNode#.mv.db ]; then
    mv /#mNode#/node/qdata/#mNode#.mv.db.bak /#mNode#/node/qdata/#mNode#.mv.db
fi

mkdir -p node/qdata/tesseraLogs

echo "Completed Tessera migration. Restart node to complete take effect."

killall NodeManager