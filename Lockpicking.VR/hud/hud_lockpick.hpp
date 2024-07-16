class hud_lockpick 
{

    idd = -1;
    fadein = 0;
    fadeout = 0;
    duration = 1e39;

    onLoad = "uiNamespace setVariable ['hud_lockpick', _this select 0]";
    onUnload = "uiNamespace setVariable ['hud_lockpick', nil]";

    class controls 
    {

        class Controls_List : Life_RscListBox 
        {

            idc = 1000;

            x = safeZoneX;
            y = safeZoneY + (0.002 * safeZoneH);
            w = 0.20 * safeZoneW;
            h = 0.15 * safeZoneH;

            font = "PuristaSemiBold";
            sizeEx = 0.02 * safeZoneH;
            rowHeight = (0.15 * safeZoneH) / 4;
            colorBackground[] = {0, 0, 0, 0};

        };

        class Lock_Outer : Life_RscPictureKeepAspect 
        {

            idc = -1;
            text = "images\lock_outer.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Inner : Life_RscPictureKeepAspect 
        {

            idc = 1001;
            text = "images\lock_inner.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Pick_Proxy : Life_RscText 
        {

            idc = 1003;
            text = "";

            x = safeZoneX;
            y = safeZoneY;
            w = 0 * safeZoneW;
            h = 0 * safeZoneH;
            
        };

    };

};

class hud_lockpick_screwdriver 
{

    idd = -1;
    fadein = 0;
    fadeout = 0;
    duration = 1e39;

    onLoad = "uiNamespace setVariable ['hud_lockpick_screwdriver', _this select 0]";
    onUnload = "uiNamespace setVariable ['hud_lockpick_screwdriver', nil]";

    class controls 
    {

        class Lock_Inner_Shadow : Life_RscPictureKeepAspect 
        {

            idc = 1003;
            text = "images\lock_shadow.paa";

            x = safeZoneX + (0.299 * safeZoneW);
            y = safeZoneY + (0.300 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Pick : Life_RscPicture
        {

            idc = 1002;
            text = "images\lock_pick.paa";

            x = safeZoneX + (0.25 * safeZoneW);
            y = safeZoneY + (0.25 * safeZoneH);
            w = 0.5 * safeZoneW;
            h = 0.5 * safeZoneH;

        };
        
    };

    class objects 
    {

        class Screwdriver : Life_RscObject 
        {

            idc = 1000;

            model = "a3\structures_f\items\tools\screwdriver_v1_f.p3d";
            inBack = 0;
            shadow = 1;

            x = safeZoneX + (0.70 * safeZoneW);
            y = safeZoneY + (0.70 * safeZoneH);
            z = 0.25;

            direction[] = {0, 1, 0}; // [east/west, north/south, up/down]
            up[] =        {0, 0, 1}; // [east/west, north/south, up/down]

        };

    };

};