#!/usr/bin/env python
import sys

userDict = {}
rev_dict = {}

from collections import defaultdict

uids = defaultdict(list)

with open(sys.argv[1],"r") as passwd_file:
  for line in passwd_file: 
    line_array = line.split(":")
    uids[line_array[1]].append(line_array[0])

for uid in uids:
  if len(uids[uid]) > 1:
    print ( uid + ": " + " ".join(uids[uid]))