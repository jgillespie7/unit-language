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
