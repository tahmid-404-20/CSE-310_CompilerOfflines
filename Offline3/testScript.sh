#!/bin/bash
# the given script is not working, so I had to write my own
#  Nafis Tahmid - 1905002
yacc -d -y 1905002.y
echo 'Generated the parser C file as well the header file'
flex 1905002.l
echo 'Generated the scanner C file'
g++ -w -g lex.yy.c y.tab.c -fsanitize=address -o out
#g++ -w -g lex.yy.c y.tab.c -o out
echo 'Linked lex.yy.c and y.tab.c files, now ready to run, use ./out <input_file>'
