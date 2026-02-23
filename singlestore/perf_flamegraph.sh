#!/bin/bash

shopt nullglob

mkdir -p flamegraphs

regex="[[:digit:]]+"

for file in perf_results/*.data; do
    cp $file perf.data

    if [[ $file =~ $regex ]]; then
        captured_number=${BASH_REMATCH[0]}
        perf script report flamegraph --allow-download -o "flamegraphs/flamegraph_${captured_number}.html"
    else
        echo "Failed to process $file."
    fi
done

