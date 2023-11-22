#!/bin/sh
ecpg App.pgc
gcc -I/usr/include/postgresql -c App.c
gcc -o App App.o -L/usr/lib -lecpg
./App