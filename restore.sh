#!/bin/bash


set -eu${DEBUG:+x}

WAIT_DB_NEXT_TRY_SECONDS=2

# Create folders for data  if not exists
mkdir -p postgresql_data
mkdir -p elastisearch_data

# Start services
docker-compose up -d db
# Wait for services
sleep 3
echo "Waiting for DB is up"
while true;
do
    echo "\dt" | docker-compose exec -T db \
        psql --username=wikijs wiki && break || \
        {
            echo "Waiting for DB, will retry in ${WAIT_DB_NEXT_TRY_SECONDS} second ";
            sleep ${WAIT_DB_NEXT_TRY_SECONDS};
        }
done
echo "Sleep 10 seconds after serices start"
sleep 10

echo "Restore DB dump"
docker-compose  \
    exec \
      -T \
      db \
        pg_restore \
            -U wikijs \
            -d wiki \
                --clean \
                --if-exists -v < wikibackup.dump


# Update search engine
echo "Update search engine"
echo  \
    "UPDATE \"searchEngines\" SET \"isEnabled\"="true", config='{\"apiVersion\":\"7.x\",\"hosts\":\"http://elasticseach:9200\",\"verifyTLSCertificate\":false,\"tlsCertPath\":\"\",\"indexName\":\"wiki\",\"analyzer\":\"simple\",\"sniffOnStart\":false,\"sniffInterval\":0}' WHERE key='elasticsearch'" \
| docker-compose exec -T db \
       psql --username=wikijs wiki

# Restart services
echo "Restart services"
docker-compose down
sleep 3
docker-compose up -d

echo "The end"
cat <<_EOF
Please check connection to Wiki: http://127.0.0.1:80

Username is "superadmin@no-such-domain.tld"
Password is "superadmin"

If you need search engine, please go to Settings page --> Search engine, apply settings and rebuild index.

_EOF