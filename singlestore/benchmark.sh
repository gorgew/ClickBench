#!/bin/bash -e

MEMSQL_PID="$1"
FREQ=${2:-"99"}

# Install

# sudo apt-get update -y
# sudo apt-get install -y docker.io
#
# export LICENSE_KEY="..."
# export ROOT_PASSWORD="..."
#
# sudo docker run -i --init \
#     --name memsql-ciab \
#     -e LICENSE_KEY="${LICENSE_KEY}" \
#     -e ROOT_PASSWORD="${ROOT_PASSWORD}" \
#     -p 3306:3306 -p 8080:8080 \
#     singlestore/cluster-in-a-box
#
# sudo docker start memsql-ciab
#
# sudo docker exec -i memsql-ciab memsql -p"${ROOT_PASSWORD}"
#
# Load the data

# sudo apt-get install -y pigz
# wget --continue --progress=dot:giga 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
# pigz -d -f hits.tsv.gz
# sudo docker cp hits.tsv memsql-ciab:/
#
# mysql -h 127.0.0.1 -u root -e "CREATE DATABASE test"
# mysql -h 127.0.0.1 -u root --database=test -e "USE test; $(cat create.sql)"
# echo -n "Load time: "
# command time -f '%e' mysql --local-infile -h 127.0.0.1  -vvv -u root --database=test -e "LOAD DATA LOCAL INFILE 'hits.tsv' INTO TABLE test.hits MAX_ERRORS 0"

# Query OK, 99997497 rows affected (11 min 30.11 sec)

mkdir -p perf_results

./run.sh $MEMSQL_PID $FREQ 2>&1 | tee log.txt

echo -n "Data size: "
du -bcs ~/memsql/ll20/memsqlbin | grep total

# 29836263469 bytes

cat log.txt |
  grep -P 'rows? in set|Empty set|^ERROR' |
  sed -r -e 's/^ERROR.*$/null/; s/^.*?\((([0-9.]+) min )?([0-9.]+) sec\).*?$/\2 \3/' |
  awk '{ if ($2 != "") { print $1 * 60 + $2 } else { print $1 } }' |
  awk '{ if (i % 3 == 0) { printf "[" }; printf $1; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'
