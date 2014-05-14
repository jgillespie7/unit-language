#ifndef FUNCTION_DATA
#define FUNCTION_DATA

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

typedef struct function_t{
	char* name;
	var_t* varArray;
	int varArrayCapacity;
	int numDeclares;
}function_t;

function_t funcArray[10];
int functionNumber=-1;

var_t* varArray;
int varArrayCapacity;
int numDeclares;

int appendElement();
int isDeclared();
unit_t getUnits();
int checkUnits();
#endif
