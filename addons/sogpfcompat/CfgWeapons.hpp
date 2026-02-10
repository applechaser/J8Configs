class CfgWeapons
{
    //SOG DLC Australian faction L1A1 may only accept 10 and 20rnd mags
    class vn_rifle762;
    class vn_l1a1_01 : vn_rifle762 {
        magazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag"};
    };
    class vn_l1a1_01_gl : vn_l1a1_01 {};
};
