#!/usr/bin/python
# hwdb-client debian installer wrapper
# you need to run this inside the root of the hwdb-client sources

import os

# variables
debianDirList = os.listdir("debian")
installerOutput = "install.sh"
outfile = []

for file in debianDirList:
    if file.endswith(".install"):
        f = open("debian/"+file,"r")
        content = f.readlines()
        f.close()
        for line in content:
            line = line.strip().split()
            if len(line) == 2:
                outfile.append("cp -Rp "+line[0]+" ${D}"+line[1])
        f.close()

# fix /usr/lib/python2.4 path
import re
newoutfile = []
for line in outfile:
    if line.find("python2.4") != -1:
        out = re.subn('2.4',"${PYVER}", line)
        line = out
    if len(line) == 2:
        newoutfile.append(line[0]+"\n")
    else:
        newoutfile.append(line+"\n")

outfile = newoutfile
del newoutfile

f = open(installerOutput,"w")
f.write("#!/bin/sh\n")
f.writelines(outfile)
f.flush()
f.close()
os.chmod(installerOutput,0700)
