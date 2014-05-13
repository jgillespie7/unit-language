#include <stdlib.h>
#include <stdio.h>
#include <math.h>

typedef enum {INT_T, FLOAT_T, DOUBLE_T} type_t;
extern void printUnits();
extern double getLengthRatio();
extern double getForceRatio();
extern double getMassRatio();
extern double getTimeRatio();

type_t string2type_t();

typedef struct var_t{
	char* name;
	type_t type;
	unit_t units;
}var_t;

var_t* varArray;
int varArrayCapacity;
int numDeclares;

int appendElement();

int isDeclared();

unit_t getUnits();

int checkUnits();
