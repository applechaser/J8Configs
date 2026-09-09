#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "J8 - Inertial NLAW guidance";
        author = "llJochemll";
        requiredVersion = 2.22;
        requiredAddons[] = {"cba_main", "ace_nlaw"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions {
    class J8_nlaw {
        class guidance {
            file = "\x\J8\addons\nlaw\functions";
            class init { file = "\x\J8\addons\nlaw\functions\fnc_init.sqf"; postInit = 1; };
            class attackProfileInit { file = "\x\J8\addons\nlaw\functions\fnc_attackProfileInit.sqf"; };
            class attackProfile { file = "\x\J8\addons\nlaw\functions\fnc_attackProfile.sqf"; };
            class navigation { file = "\x\J8\addons\nlaw\functions\fnc_navigation.sqf"; };
            class seekerInit { file = "\x\J8\addons\nlaw\functions\fnc_seekerInit.sqf"; };
            class seeker { file = "\x\J8\addons\nlaw\functions\fnc_seeker.sqf"; };
        };
    };
};

class ace_missileguidance_NavigationTypes {
    class ace_nlaw_PLOS {
        functionName = "J8_nlaw_fnc_navigation";
        onFired = ""; // Navigation initializes its private filter state on first use.
    };
};

class ace_missileguidance_SeekerTypes {
    class ace_nlaw_seeker {
        functionName = "J8_nlaw_fnc_seeker";
        onFired = "J8_nlaw_fnc_seekerInit";
    };
};

class ace_missileguidance_AttackProfiles {
    class ace_nlaw_directAttack {
        functionName = "J8_nlaw_fnc_attackProfile";
        onFired = "J8_nlaw_fnc_attackProfileInit";
    };
    class ace_nlaw_overflyTopAttack: ace_nlaw_directAttack {
        functionName = "J8_nlaw_fnc_attackProfile";
        onFired = "J8_nlaw_fnc_attackProfileInit";
    };
};

class ace_missileguidance_type_Nlaw;
class CfgAmmo {
    class M_NLAW_AT_F;
    class ACE_NLAW: M_NLAW_AT_F {
        class ace_missileguidance: ace_missileguidance_type_Nlaw {
            enabled = 1;
            pitchRate = 120;
            yawRate = 120;
            // Each framework component owns its own initialization.
            // Disable ACE's legacy all-in-one target-aware initializer.
            onFired = "";
        };
    };
};
