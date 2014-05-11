eng: lex.yy.c eng.tab.h eng.tab.c unit.c
	gcc -o eng lex.yy.c eng.tab.c unit.c -lfl

lex.yy.c: eng.l eng.tab.h unit.h varArray.c
	flex eng.l

eng.tab.c eng.tab.h: eng.y unit.h varArray.c
	bison -d eng.y

clean:
	rm -f lex.yy.c eng.tab.h eng.tab.c
