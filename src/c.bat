pclex lexer.l
bison parser.y -o parser.c 
bcc -c sioxc.c > errores.txt
bcc sioxc.c
copy sioxc.exe c:\archiv~1\mplab

