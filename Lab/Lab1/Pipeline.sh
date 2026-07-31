#!/bin/bash

# Count the Lines  and print3 files
echo -e"Count the Lines  and print3 files "
wc -l a.txt b.txt c.tsv


# print 3 Lines from b.txt
echo -e "Print 3 lines from B.txt"
head -n 3 b.txt 

# Paste a.txt and c.tsv and print 
paste a.txt c.tsv > Data.tsv
cat Data.tsv

#Print 3rd column from c.tsv
cut -f 3 c.tsv

grep -i "name" a.txt
