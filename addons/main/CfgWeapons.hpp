class CfgWeapons
{
    class arifle_MX_Base_F;
    //regular MX may only accept 30rnd Mags
    class arifle_MX_F: arifle_MX_Base_F {
        magazineWell[] = {"MX_65x39","CBA_65x39_MX"};
    };
    class arifle_MX_GL_F: arifle_MX_Base_F {
        magazineWell[] = {"MX_65x39","CBA_65x39_MX"};
    };
    class arifle_MXC_F: arifle_MX_Base_F {
        magazineWell[] = {"MX_65x39","CBA_65x39_MX"};
    };
    class arifle_MXM_F: arifle_MX_Base_F {
        magazineWell[] = {"MX_65x39","CBA_65x39_MX"};
    };
    //MXAR and variants may only accept 30rnd Mags
    class ef_arifle_mxar: arifle_MX_Base_F {
        magazineWell[] = {"MX_65x39","CBA_65x39_MX"};
    };

    //SOG DLC Australian faction L1A1 may only accept 10 and 20rnd mags
    class vn_l1a1_01 : arifle_MX_Base_F {
        magazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag"};
        magazineWell[] = {};
    };
    class vn_l1a1_01_gl : arifle_MX_Base_F {
        magazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag"};
        magazineWell[] = {};
    };

};