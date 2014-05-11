#include <stdlib.h>
#include <stdio.h>

typedef enum {INT_T, FLOAT_T, DOUBLE_T} type_t;

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

var_t* varArray;
int varArrayCapacity = 0;
int numDeclares = 0;

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
			return 1;
		}
	}
	return 0;
}


