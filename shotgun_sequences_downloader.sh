#!/bin/sh
input="./SraAccList.txt"
while IFS= read -r line
do
  echo "$line"
done
