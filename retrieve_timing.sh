#!/bin/bash
set -e

root=$1
cd $root

rm -f runtimes.tab

for method in sp ap oadp; do
    runtime=$( cat *.log | grep -A 1 --no-group-separator "${method}".pcs | awk 'NR % 2 == 0' | cut -d' ' -f3 | Rscript -e 'x=scan("stdin", quiet=T); cat(round(mean(x)), "\n")' )
    echo $method $runtime >> runtimes.tab
done

cat *.log | grep 'Oct.*2019' | grep -B 1 --no-group-separator 'Finished at: ' > tmp_timestamps
cat tmp_timestamps | awk 'NR % 2 == 1' > tmp_start
cat tmp_timestamps | awk 'NR % 2 == 0' | cut -d':' -f2- > tmp_end

for tmp_file in tmp_start tmp_end; do
    rm -f ${tmp_file}_epoch
    while read line; do
        date --date="$line" +"%s" >> ${tmp_file}_epoch
    done < $tmp_file
done

runtime_adp=$( paste tmp_start_epoch tmp_end_epoch | awk '{ print $2 - $1 }' | Rscript -e 'x=scan("stdin", quiet=T); cat(round(mean(x)), "\n")' )
echo adp $runtime_adp >> runtimes.tab

cat runtimes.tab
rm -r tmp_*
