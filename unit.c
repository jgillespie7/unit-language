#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

extern int line_num;

typedef enum {M, CM, MM, KM, FT, IN, MI} length_t;
typedef enum {N, LBF} force_t;
typedef enum {KG, LB} mass_t;
typedef enum {S, MIN, HR} timeU_t;


typedef struct unit_t{
	length_t lengthUnit;
	int lengthPower;
	force_t forceUnit;
	int forcePower;
	mass_t massUnit;
	int massPower;
	timeU_t timeUnit;
	int timePower;
}unit_t;

const struct unit_t UNIT_DEFAULT;

void printUnits(unit_t unit, char* returnString) {
	char output[20];
	sprintf(output, "");
	char* length = malloc(sizeof(char)*4);
        char* force = malloc(sizeof(char)*4);
	char* mass = malloc(sizeof(char)*4);
        char* time = malloc(sizeof(char)*4);
	switch (unit.lengthUnit){
		case M:
			strcpy(length, "m");
			break;
		case MM:
			strcpy(length, "mm");
			break;
		case CM:
			strcpy(length, "cm");
			break;
		case KM:
			strcpy(length, "km");
			break;
		case FT:
			strcpy(length, "ft");
			break;
		case IN:
			strcpy(length, "in");
			break;
		case MI:
			strcpy(length, "mi");
			break;
		default:
			printf("Error\n");
	}
	if (unit.lengthPower == 0) {
	}
	else if (unit.lengthPower == 1) {
		sprintf(output, "%s%s", output, length);
	}
	else {
		sprintf(output, "%s%s^%d", output, length, unit.lengthPower);
	}
	switch (unit.forceUnit){
		case N:
			strcpy(force, "N");
			break;
		case LBF:
			strcpy(force, "lbf");
			break;
		default:
			printf("Error\n");
	}
	if (unit.forcePower == 0) {
	}
	else if (unit.forcePower == 1) {
		if (unit.lengthPower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s", output, force);
	}
	else {
		if (unit.lengthPower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s^%d", output, force, unit.forcePower);
	}
	switch (unit.massUnit){
		case KG:
			strcpy(mass, "kg");
			break;
		case LB:
			strcpy(mass, "lb");
			break;
		default:
			printf("Error\n");
	}
	if (unit.massPower == 0) {
	}
	else if (unit.massPower == 1) {
		if (unit.lengthPower>0 || unit.forcePower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s", output, mass);
	}
	else {
		if (unit.lengthPower>0 || unit.forcePower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s^%d", output, mass, unit.massPower);
	}
	switch (unit.timeUnit){
		case S:
			strcpy(time, "s");
			break;
		case MIN:
			strcpy(time, "min");
			break;
		case HR:
			strcpy(time, "hr");
			break;
		default:
			printf("Error\n");
	}
	if (unit.timePower == 0) {
	}
	else if (unit.timePower == 1) {
		if (unit.lengthPower>0 || unit.forcePower>0 || unit.massPower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s", output, time);
	}
	else {
		if (unit.lengthPower>0 || unit.forcePower>0 || unit.massPower>0) {
			sprintf(output, "%s*", output);
		}
		sprintf(output, "%s%s^%d", output, time, unit.timePower);
	}
	free(length); free(force); free(mass); free(time);
	strcpy(returnString, output);
}

double getLengthRatio(length_t lengthUnit) {
	switch (lengthUnit){
		case M:
			return 1;
		case MM:
			return .001;
		case CM:
			return .01;
		case KM:
			return 1000;
		case FT:
			return .3048;
		case IN:
			return .0254;
		case MI:
			return 1609.344;
		default:
			fprintf(stderr, "Error: Something went wrong in getLengthRatio\n");
			exit(-1);
	}
}

double getForceRatio(force_t forceUnit) {
	switch (forceUnit){
		case N:
			return 1;
		case LBF:
			return 4.44822162;
		default:
			printf("%d", forceUnit);
			fprintf(stderr, "Error: Something went wrong in getForceRatio\n");
			exit(-1);
	}
}

double getMassRatio(mass_t massUnit) {
	switch (massUnit){
		case KG:
			return 1;
		case LB:
			return 0.453592;
		default:
			fprintf(stderr, "Error: Something went wrong in getMassRatio\n");
			exit(-1);
	}
}

double getTimeRatio(timeU_t timeUnit) {
	switch (timeUnit){
		case S:
			return 1;
		case MIN:
			return 60;
		case HR:
			return 3600;
		default:
			fprintf(stderr, "Error: Something went wrong in getTimeRatio\n");
			exit(-1);
	}
}

unit_t multUnits(unit_t unit1, unit_t unit2, double* ratio) {
	unit_t unitOut=UNIT_DEFAULT;
	*ratio = 1;
	if ( unit1.lengthPower == 0 ) {
		unitOut.lengthPower = unit2.lengthPower;
		unitOut.lengthUnit = unit2.lengthUnit;
	}
	else if ( unit2.lengthPower == 0 ) {
		unitOut.lengthPower = unit1.lengthPower;
		unitOut.lengthUnit = unit1.lengthUnit;
	}
	else {
		unitOut.lengthPower = unit1.lengthPower + unit2.lengthPower;
		unitOut.lengthUnit = unit1.lengthUnit;
		*ratio = *ratio*pow((getLengthRatio(unit2.lengthUnit)/getLengthRatio(unit1.lengthUnit)),unit2.lengthPower);
	}
	if ( unit1.forcePower == 0 ) {
		unitOut.forcePower = unit2.forcePower;
		unitOut.forceUnit = unit2.forceUnit;
	}
	else if ( unit2.forcePower == 0 ) {
		unitOut.forcePower = unit1.forcePower;
		unitOut.forceUnit = unit1.forceUnit;
	}
	else {
		unitOut.forcePower = unit1.forcePower + unit2.forcePower;
		unitOut.forceUnit = unit1.forceUnit;
		*ratio = *ratio*pow((getForceRatio(unit2.forceUnit)/getForceRatio(unit1.forceUnit)),unit2.forcePower);
	}
	if ( unit1.massPower == 0 ) {
		unitOut.massPower = unit2.massPower;
		unitOut.massUnit = unit2.massUnit;
	}
	else if ( unit2.massPower == 0 ) {
		unitOut.massPower = unit1.massPower;
		unitOut.massUnit = unit1.massUnit;
	}
	else {
		unitOut.massPower = unit1.massPower + unit2.massPower;
		unitOut.massUnit = unit1.massUnit;
		*ratio = *ratio*pow((getMassRatio(unit2.massUnit)/getMassRatio(unit1.massUnit)),unit2.massPower);
	}
	if ( unit1.timePower == 0 ) {
		unitOut.timePower = unit2.timePower;
		unitOut.timeUnit = unit2.timeUnit;
	}
	else if ( unit2.timePower == 0 ) {
		unitOut.timePower = unit1.timePower;
		unitOut.timeUnit = unit1.timeUnit;
	}
	else {
		unitOut.timePower = unit1.timePower + unit2.timePower;
		unitOut.timeUnit = unit1.timeUnit;
		*ratio = *ratio*pow((getTimeRatio(unit2.timeUnit)/getTimeRatio(unit1.timeUnit)),unit2.timePower);
	}
	return unitOut;
}

unit_t divUnits(unit_t unit1, unit_t unit2, double* ratio) {
	unit_t unitOut;
	*ratio = 1;
	if ( unit1.lengthPower == 0 ) {
		unitOut.lengthPower = -unit2.lengthPower;
		unitOut.lengthUnit = unit2.lengthUnit;
	}
	else if ( unit2.lengthPower == 0 ) {
		unitOut.lengthPower = unit1.lengthPower;
		unitOut.lengthUnit = unit1.lengthUnit;
	}
	else {
		unitOut.lengthPower = unit1.lengthPower - unit2.lengthPower;
		unitOut.lengthUnit = unit1.lengthUnit;
		*ratio = *ratio*pow((getLengthRatio(unit2.lengthUnit)/getLengthRatio(unit1.lengthUnit)),unit2.lengthPower);
	}
	if ( unit1.forcePower == 0 ) {
		unitOut.forcePower = -unit2.forcePower;
		unitOut.forceUnit = unit2.forceUnit;
	}
	else if ( unit2.forcePower == 0 ) {
		unitOut.forcePower = unit1.forcePower;
		unitOut.forceUnit = unit1.forceUnit;
	}
	else {
		unitOut.forcePower = unit1.forcePower - unit2.forcePower;
		unitOut.forceUnit = unit1.forceUnit;
		*ratio = *ratio*pow((getForceRatio(unit2.forceUnit)/getForceRatio(unit1.forceUnit)),unit2.forcePower);
	}
	if ( unit1.massPower == 0 ) {
		unitOut.massPower = -unit2.massPower;
		unitOut.massUnit = unit2.massUnit;
	}
	else if ( unit2.massPower == 0 ) {
		unitOut.massPower = unit1.massPower;
		unitOut.massUnit = unit1.massUnit;
	}
	else {
		unitOut.massPower = unit1.massPower - unit2.massPower;
		unitOut.massUnit = unit1.massUnit;
		*ratio = *ratio*pow((getMassRatio(unit2.massUnit)/getMassRatio(unit1.massUnit)),unit2.massPower);
	}
	if ( unit1.timePower == 0 ) {
		unitOut.timePower = -unit2.timePower;
		unitOut.timeUnit = unit2.timeUnit;
	}
	else if ( unit2.timePower == 0 ) {
		unitOut.timePower = unit1.timePower;
		unitOut.timeUnit = unit1.timeUnit;
	}
	else {
		unitOut.timePower = unit1.timePower - unit2.timePower;
		unitOut.timeUnit = unit1.timeUnit;
		*ratio = *ratio*pow((getTimeRatio(unit2.timeUnit)/getTimeRatio(unit1.timeUnit)),unit2.timePower);
	}	return unitOut;
}

unit_t addUnits(unit_t unit1, unit_t unit2, double* ratio) {
	if ((unit1.lengthPower !=  unit2.lengthPower) ||
		(unit1.forcePower !=  unit2.forcePower) ||
		(unit1.massPower !=  unit2.massPower) ||
		(unit1.timePower !=  unit2.timePower)) {
		char buf1[20]; char buf2[20];
		printUnits(unit1, buf1), printUnits(unit2, buf2);
		fprintf(stderr, "Error: Adding incompatible units on line %d: \"%s\" and \"%s\"\n", line_num, buf1, buf2);
		exit(-1);
	}
	*ratio = pow((getLengthRatio(unit2.lengthUnit)/getLengthRatio(unit1.lengthUnit)),unit1.lengthPower)*
		pow((getForceRatio(unit2.forceUnit)/getForceRatio(unit1.forceUnit)),unit1.lengthPower)*
		pow((getMassRatio(unit2.massUnit)/getMassRatio(unit1.massUnit)),unit1.lengthPower)*
		pow((getTimeRatio(unit2.timeUnit)/getTimeRatio(unit1.timeUnit)),unit1.lengthPower);
	return unit1;
}

unit_t subUnits(unit_t unit1, unit_t unit2, double* ratio) {
	if ((unit1.lengthPower !=  unit2.lengthPower) ||
		(unit1.forcePower !=  unit2.forcePower) ||
		(unit1.massPower !=  unit2.massPower) ||
		(unit1.timePower !=  unit2.timePower)) {
		char buf1[20]; char buf2[20];
		printUnits(unit1, buf1); printUnits(unit2, buf2);
		fprintf(stderr, "Error: Subtracting incompatible units on line %d: \"%s\" and \"%s\"\n", line_num, buf1, buf2);
		exit(-1);
	}
	*ratio = pow((getLengthRatio(unit2.lengthUnit)/getLengthRatio(unit1.lengthUnit)),unit1.lengthPower)*
		pow((getForceRatio(unit2.forceUnit)/getForceRatio(unit1.forceUnit)),unit1.lengthPower)*
		pow((getMassRatio(unit2.massUnit)/getMassRatio(unit1.massUnit)),unit1.lengthPower)*
		pow((getTimeRatio(unit2.timeUnit)/getTimeRatio(unit1.timeUnit)),unit1.lengthPower);
	return unit1;
}

void string2unit_t(char* input, unit_t* unit) {
	*unit = UNIT_DEFAULT;
	if (strcmp(input, "m")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=M;
	}
	else if (strcmp(input, "cm")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=CM;
	}
	else if (strcmp(input, "mm")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=MM;
	}
	else if (strcmp(input, "km")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=KM;
	}
	else if (strcmp(input, "ft")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=FT;
	}
	else if (strcmp(input, "in")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=IN;
	}
	else if (strcmp(input, "mi")==0) {
		(*unit).lengthPower=1;
		(*unit).lengthUnit=MI;
	}
	else if (strcmp(input, "N")==0) {
		(*unit).forcePower=1;
		(*unit).forceUnit=N;
	}
	else if (strcmp(input, "lbf")==0) {
		(*unit).forcePower=1;
		(*unit).forceUnit=LBF;
	}
	else if (strcmp(input, "kg")==0) {
		(*unit).massPower=1;
		(*unit).massUnit=KG;
	}
	else if (strcmp(input, "lb")==0 || strcmp(input, "lbm")==0) {
		(*unit).massPower=1;
		(*unit).massUnit=LB;
	}
	else if (strcmp(input, "s")==0) {
		(*unit).timePower=1;
		(*unit).timeUnit=S;
	}
	else if (strcmp(input, "min")==0) {
		(*unit).timePower=1;
		(*unit).timeUnit=MIN;
	}
	else if (strcmp(input, "hr")==0) {
		(*unit).timePower=1;
		(*unit).timeUnit=HR;
	}
	else {
		fprintf(stderr, "Error: Unrecognized unit %s on line %d. Stopping\n", input, line_num);
		exit(-1);
	}
}
