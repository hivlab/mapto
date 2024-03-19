#!/bin/bash

jid=`sbatch bt2-index.sh | awk '{print $NF }'`
echo $jid

jid=`sbatch --dependency=afterok:$jid --kill-on-invalid-dep=yes bt2-map.sh | awk '{print $NF }'`
echo $jid
