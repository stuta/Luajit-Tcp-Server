#!/bin/sh
LD_PRELOAD=/usr/lib/i386-linux-gnu/librt.so luajit $*

# run: "locate librt.so" and replace path "/usr/lib/i386-linux-gnu/librt.so" in line 2
# after copying this file run "chmod +x ./lj.sh"
# after installing luajit run: 
# sudo ln -s /usr/local/bin/lj path_to_this_file/lj.sh
# example: sudo ln ~/Documents/lua/lj.sh -s /usr/local/bin/lj
# then instead of "luajit myprogram.lua" run "lj myprogram.lua"
