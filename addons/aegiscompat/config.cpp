#include "script_component.hpp"

class cfgPatches {
    class ADDON {
        name = "J8";
        author = "applechaser";
        units[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"cba_main", "A3_Aegis_Characters_F_Aegis"};
        skipWhenMissingDependencies = 1;
    };
};

#include "cfgVehicles.hpp"
