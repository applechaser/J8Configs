#define PREFIX J5
#define COMPONENT main

#include "\x\cba\addons\main\script_macros_common.hpp"

#undef PREP
#define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction