#!/bin/bash
#################################################
# Algorithmics checker
#################################################
# Setup:
#  1. Copy/paste into test.sh
#  2. chmod +x test.sh
#
# Usage:
#  1. ./test.sh data6.txt
#  2. After a few seconds the script will output:
#       * Execution time for finding shortest path
#       * The shortest distance from a to b in the given graph
#       * The shortest path from a to b in the given graph
# Known output:
#   data6.txt:
#       dist = 11
#       path = 2 1 0 5
#   data20.txt:
#       dist = 1199
#       path = 3 0 4
#   data40.txt:
#       dist = 1157
#       path = 3 36 4
#   data60.txt:
#       dist = 1152
#       path = 3 49 4
#   data80.txt:
#       dist = 1152
#       path = 4 49 3
#   data1000.txt:
#       dist = 17
#       path = 24 582 964 837 152

# Grab the data, standardize it
DATA="$(cat $1 | sed '/^$/d')"

# Generate matlab style matrix
ARR="[$(echo "$DATA" | tail -n+2 | head -n-1 | perl -pe 's/\n/; \n/g')]"

# Grab the to/from nodes
FROM=$(echo "$DATA" | tail -n1 | cut -f1 -d' ')
TO=$(echo "$DATA" | tail -n1 | cut -f2 -d' ')

# Generate matlab code to calculate shortest path
TEMP=$(mktemp)
echo "G = sparse($ARR)" > $TEMP
echo "time = cputime" >> $TEMP
echo "[dist, path, pred] = graphshortestpath(G, $(expr $FROM + 1), $(expr $TO + 1))" >> $TEMP
echo "time = cputime - time" >> $TEMP
echo "distance = dist" >> $TEMP
echo "path = path - 1" >> $TEMP

# Run code through matlab
matlab -nosplash < $TEMP | tail -n15 | sed '/^>>/d;/^$/d'

# Delete temp file
rm $TEMP
