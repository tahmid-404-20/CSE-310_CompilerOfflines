#!/bin/bash

yacc -d -y parser.y
echo 'Generated the parser C file as well the header file'
g++  -fsanitize=address -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 1905002_scanner.l
echo 'Generated the scanner C file'
g++  -fsanitize=address -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++  -fsanitize=address y.o l.o -lfl -o output
echo 'All ready, running'
./output inp.txt
