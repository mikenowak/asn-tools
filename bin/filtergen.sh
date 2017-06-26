#!/bin/bash
#
# Mike Nowak <https://www.github.com/mikenowak/>
#

FAMILY=$1
AS=$2
IMPORT=$3

# Validate input
if [ $# -lt 2 ]; then
  echo "Usage: routebuilder 4|6 AS IMPORT"
  exit 1
fi

if [ "${FAMILY}" != "4" -a "${FAMILY}" != "6" ]; then
  echo "ERROR: Invalid family, must be 4 or 6"
  exit 1
fi


# Set minimum prefix to filter out
case "${FAMILY}" in
  4) MINIMUM=25 ;;
  6) MINIMUM=49 ;;
esac

if [ "${IMPORT}" == "ANY" ]; then
  case "${FAMILY}" in
    4) PREFIXES="0.0.0.0/0";;
    6) PREFIXES="::/0";;
  esac
else
  PREFIXES=$(./bgpq3 -3 -${FAMILY} -m ${MINIMUM} -F "%n/%l " ${IMPORT})
fi

# strip extra caracters
AS=$(echo ${AS} | sed 's/:/--/g')

# Delete existing prefix-list
case ${FAMILY} in
  4)
    echo "delete policy prefix-list prefix4-${AS}"
  ;;
  6)
    echo "delete policy prefix-list6 prefix6-${AS}"
  ;;
 esac

# Iterate through the list of all prefixes for given family and build a prefix-list
i=1;
for prefix in ${PREFIXES}; do
  case ${FAMILY} in
    4)
      echo "set policy prefix-list prefix4-${AS} rule ${i} action permit"
      echo "set policy prefix-list prefix4-${AS} rule ${i} prefix ${prefix}"
    ;;
    6)
      echo "set policy prefix-list6 prefix6-${AS} rule ${i} action permit"
      echo "set policy prefix-list6 prefix6-${AS} rule ${i} prefix ${prefix}"
    ;;
   esac
  ((i++))
done
