eng: lex.yy.c eng.tab.h eng.tab.c unit.c unit.h varArray.c varArray.h
	gcc -o eng lex.yy.c eng.tab.c unit.c varArray.c -lfl -lm

lex.yy.c: eng.l eng.tab.h unit.h varArray.h
	flex eng.l

eng.tab.c eng.tab.h: eng.y unit.h varArray.h
	bison -d eng.y

clean:
	rm -f lex.yy.c eng.tab.h eng.tab.c
