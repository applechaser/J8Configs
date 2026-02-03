class CfgWeapons
{
    class ItemCore;
    class Vest_Camo_Base : ItemCore {
        class ItemInfo;
    };

    //Fix UKSF Vest capacity
    //make seperate compat PBO per mod
    class P_UKSF_JPC2_MC : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply160";
            mass = 100;
        };
    };
    class P_UKSF_JPC2_V2_MC : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply160";
            mass = 100;
        };
    };
    class P_UKSF_JPC2_V3_MC : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply150";
            mass = 100;
        };
    };
    class P_UKSF_JPC2_V4_MC : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply180";
            mass = 100;
        };
    };
    class P_UKSF_JPC2_V5_MC : Vest_Camo_Base {
        class ItemInfo : ItemInfo {
            containerClass = "Supply150";
            mass = 100;
        };
    };
};
