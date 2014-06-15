#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "unit.h"

typedef enum {INT_T, FLOAT_T, DOUBLE_T} type_t;
extern void printUnits();
extern double getLengthRatio();
extern double getForceRatio();
extern double getMassRatio();
extern double getTimeRatio();

type_t string2type_t(char* input) {
	if (strcmp(input, "int")==0) {
		return INT_T;
	}
	if (strcmp(input, "float")==0) {
		return FLOAT_T;
	}
	if (strcmp(input, "double")==0) {
		return DOUBLE_T;
	}
	fprintf(stderr, "Error: Type %s is not supported\n", input);
	exit(-1);
}

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

int appendElement(var_t element, var_t** varArray, int* capacity, int* numElements) {
	if (*capacity==0) {
		*varArray = malloc(sizeof(var_t));
		*capacity = 1;
	}
	if (*numElements == *capacity) {
		var_t tempDeclaration[*capacity];
		int i;
		for (i=0; i<*numElements; i++) {
			tempDeclaration[i]=(*varArray)[i];
		}
		free(*varArray);
		*varArray = malloc(sizeof(var_t)*(*capacity)*2);
		for (i=0; i<*numElements; i++) {
			(*varArray)[i]=tempDeclaration[i];
		}
		*capacity = *capacity * 2;
	}
	(*varArray)[*numElements] = element;
	(*numElements)++;
}

int isDeclared(var_t* varArray, int numDeclares, char* idName) {
	int i;
	for (i=0; i<numDeclares; i++) {
		if (strcmp(idName, varArray[i].name)==0) {
			return i+1;
		}
	}
	return 0;
}

int isFunctionDeclared(var_t* funcArray, int functionNumber, char* idName) {
	int i;
	for (i=0; i<functionNumber; i++) {
		if (strcmp(idName, funcArray[i].name)==0) {
			return i+1;
		}
	}
	return 0;
}

unit_t getUnits(var_t* varArray, int numDeclares, char* idName) {
	int i;
	for (i=0; i<numDeclares; i++) {
		if (strcmp(idName, varArray[i].name)==0) {
			return varArray[i].units;
		}
	}
	exit(-1);
}



int checkUnits(unit_t unit1, unit_t unit2, double* ratio) {
	if ((unit1.lengthPower !=  unit2.lengthPower) ||
		(unit1.forcePower !=  unit2.forcePower) ||
		(unit1.massPower !=  unit2.massPower) ||
		(unit1.timePower !=  unit2.timePower)) {
		return 0;
	}
	*ratio = pow((getLengthRatio(unit2.lengthUnit)/getLengthRatio(unit1.lengthUnit)),unit1.lengthPower)*
	pow((getForceRatio(unit2.forceUnit)/getForceRatio(unit1.forceUnit)),unit1.lengthPower)*
	pow((getMassRatio(unit2.massUnit)/getMassRatio(unit1.massUnit)),unit1.lengthPower)*
	pow((getTimeRatio(unit2.timeUnit)/getTimeRatio(unit1.timeUnit)),unit1.lengthPower);
	return 1;
}
