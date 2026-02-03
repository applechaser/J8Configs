#include "script_component.hpp"

class cfgPatches {
    class ADDON {
        name = "J8";
        author = "applechaser";
        units[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"cba_main", "CUP_Weapons_LoadOrder"};
        skipWhenMissingDependencies = 1;
    };
};

#include "CfgAmmo.hpp"
