#!/bin/bash

TRIES=3
OUTPUT=""

cat queries.sql | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches

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
done;
