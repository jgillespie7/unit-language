#include <stdio.h>
#include <stdlib.h>

extern int line_num;

typedef enum {M, CM, MM, KM, FT, IN} length_t;
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

void string2unit_t(char* input, unit_t* unit) {
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
		fprintf(stderr, "Error: Unrecognized unit %s on line %d. Stopping", input, line_num);
		exit(-1);
	}

}
