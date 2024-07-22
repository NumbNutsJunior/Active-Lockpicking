
class RscLine : RscText
{

    style = ST_LINE;
    colorText[] = {1, 1, 1, 1};

    x = safeZoneX;
    y = safeZoneY;
    w = safezoneW;
    h = safeZoneH;

};

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

        class Controls_List : RscListBox 
        {

            idc = 1000;

            x = safeZoneX;
            y = safeZoneY;
            w = 0.20 * safeZoneW;
            h = 0.15 * safeZoneH;

            font = "PuristaSemiBold";
            sizeEx = 0.02 * safeZoneH;
            rowHeight = (0.15 * safeZoneH) / 4;
            colorBackground[] = {0, 0, 0, 0};

        };

        class Lock_Outer : RscPictureKeepAspect 
        {

            idc = -1;
            text = "images\lock_outer.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Inner : RscPictureKeepAspect 
        {

            idc = 1001;
            text = "images\lock_inner.paa";

            x = safeZoneX + (0.3 * safeZoneW);
            y = safeZoneY + (0.3 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Pick_Proxy : RscBackground 
        {

            idc = 1003;
            text = "";

            x = safeZoneX;
            y = safeZoneY;
            w = 0 * safeZoneW;
            h = 0 * safeZoneH;
            
        };

        // ...
        #define INFO_LIST_BORDER_LEFT_THICKNESS ((1 * pixelW * pixelGridNoUIScale) / 5)
        #define INFO_LIST_BORDER_BOTTOM_THICKNESS ((1 * pixelH * pixelGridNoUIScale) / 5)
        #define INFO_LIST_PADDING_X (1 * pixelW * pixelGridNoUIScale)
        #define INFO_LIST_PADDING_Y (1 * pixelH * pixelGridNoUIScale)
        #define INFO_LIST_X (safeZoneX + INFO_LIST_PADDING_X)
        #define INFO_LIST_Y ((safeZoneY + safeZoneH) - INFO_LIST_HEIGHT - INFO_LIST_PADDING_Y)
        #define INFO_LIST_HEIGHT (0.100 * safeZoneH)
        #define INFO_LIST_WIDTH (0.175 * safeZoneW)

        class Info_List_Background_Left : RscBackground
        {

            idc = -1;

            x = INFO_LIST_X;
            y = INFO_LIST_Y - INFO_LIST_PADDING_Y;
            w = INFO_LIST_BORDER_LEFT_THICKNESS;
            h = INFO_LIST_HEIGHT + INFO_LIST_PADDING_Y;

            colorBackground[] = {1, 1, 1, 0.75};

        };

        class Info_List_Background_Bottom : RscBackground
        {

            idc = -1;

            x = INFO_LIST_X + INFO_LIST_BORDER_LEFT_THICKNESS;
            y = INFO_LIST_Y + INFO_LIST_HEIGHT - INFO_LIST_BORDER_BOTTOM_THICKNESS;
            w = INFO_LIST_WIDTH - INFO_LIST_BORDER_LEFT_THICKNESS;
            h = INFO_LIST_BORDER_BOTTOM_THICKNESS;

            colorBackground[] = {1, 1, 1, 0.75};

        };

        class Info_List : RscListBox 
        {

            idc = 1004;

            x = INFO_LIST_X + INFO_LIST_PADDING_X;
            y = INFO_LIST_Y - INFO_LIST_PADDING_Y;
            w = INFO_LIST_WIDTH;
            h = INFO_LIST_HEIGHT;

            font = "PuristaSemiBold";
            sizeEx = 0.03 * safeZoneH;
            rowHeight = INFO_LIST_HEIGHT / 2;
            colorBackground[] = {0, 0, 0, 0};

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

        class Lock_Inner_Shadow : RscPictureKeepAspect 
        {

            idc = 1003;
            text = "images\lock_shadow.paa";

            x = safeZoneX + (0.299 * safeZoneW);
            y = safeZoneY + (0.300 * safeZoneH);
            w = 0.4 * safeZoneW;
            h = 0.4 * safeZoneH;

        };

        class Lock_Pick : RscPictureKeepAspect
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

        class Screwdriver : RscObject 
        {

            idc = 1000;

            model = "\A3\Structures_F\Items\Tools\Screwdriver_V1_F.p3d";
            inBack = 0;
            shadow = 1;

            x = safeZoneX;
            y = safeZoneY;
            z = 0.50;

            direction[] = {0, 1, 0};
            up[] =        {0, 0, 1};

        };

    };

};