#!/bin/bash

# Arguments:
# ./run.sh memsql_pid freq(optional)
MEMSQL_PID="$1"
FREQ=${2:-"99"}

TRIES=3
OUTPUT=""

QUERY_NUMBER=1

cat queries.sql | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches

    perf record -p "${MEMSQL_PID}" -F $FREQ -g -o "perf_results/query_${QUERY_NUMBER}_perf.data" &
    mysql -h 127.0.0.1 -u root -vvv --database=test -e "USE test; ${query}"

    # to get the most accurate 'hot' query results, wait for async compilations to finish to ensure we have a compiled plan
    while [[ "$OUTPUT" != *"Inflight_async_compilations | 0"* ]]; do
        sleep 1
        OUTPUT=$( mysql -h 127.0.0.1 -u root -vvv --database=test -e "show status like 'Inflight_async_compilations'")
        echo "sleeping"
    done

    for i in $(seq 2 $TRIES); do
        mysql -h 127.0.0.1 -u root -vvv --database=test -e "USE test; ${query}"
    done;

    kill $!

    ((QUERY_NUMBER++))
done;
