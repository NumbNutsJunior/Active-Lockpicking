class hud_lockpick {

    idd = -1;
    fadein = 0;
    fadeout = 0;
    duration = 1e39;

    onLoad = "uiNamespace setVariable ['hud_lockpick', _this select 0]";
    onUnload = "uiNamespace setVariable ['hud_lockpick', nil]";

    class controls {

        class Lock_Outer : Life_RscPictureKeepAspect {

            idc = -1;
            text = "images\lock_outer.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;
        };

        class Lock_Inner : Life_RscPictureKeepAspect {

            idc = 1000;
            text = "images\lock_inner.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;
        };

        class Lock_Pick : Life_RscPicture {

            idc = 1001;
            text = "images\lock_pick.paa";

            x = safeZoneX + (0.297 * safeZoneW);
            y = safeZoneY + (0.216 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.6 * safeZoneH;
        };

        class Lock_Pick_Proxy : Life_RscText {

            idc = 1002;
            text = "";

            x = safeZoneX;
            y = safeZoneY;
            w = 0 * safeZoneW;
            h = 0 * safeZoneH;
        };

        class Controls_List : Life_RscListBox {

            idc = 1003;

            x = safeZoneX;
            y = safeZoneY + (0.002 * safeZoneH);
            w = 0.20 * safeZoneW;
            h = 0.15 * safeZoneH;

            font = "PuristaSemiBold";
            sizeEx = 0.02 * safeZoneH;
            rowHeight = (0.15 * safeZoneH) / 4;
            colorBackground[] = {0, 0, 0, 0};
        };
    };
};
