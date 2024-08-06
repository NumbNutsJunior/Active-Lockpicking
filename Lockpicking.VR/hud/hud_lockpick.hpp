
// ...
#define LOCK_IMAGE_SIZE_W (pixelW * pixelGridNoUIScale * 30)
#define LOCK_IMAGE_SIZE_H (pixelH * pixelGridNoUIScale * 30)

// ...
#define LOCK_IMAGE_X ((safeZoneX + (0.5 * safeZoneW)) - (LOCK_IMAGE_SIZE_W / 2))
#define LOCK_IMAGE_Y ((safeZoneY + (0.5 * safeZoneH)) - (LOCK_IMAGE_SIZE_H / 2))

// ...
#define LOCK_PICK_IMAGE_SIZE_W (LOCK_IMAGE_SIZE_W * 1.25)
#define LOCK_PICK_IMAGE_SIZE_H (LOCK_IMAGE_SIZE_H * 1.25)

// ...
#define LOCK_PICK_IMAGE_X ((safeZoneX + (0.5 * safeZoneW)) - (LOCK_PICK_IMAGE_SIZE_W / 2))
#define LOCK_PICK_IMAGE_Y ((safeZoneY + (0.5 * safeZoneH)) - (LOCK_PICK_IMAGE_SIZE_H / 2))

// ...
#define CONTROLS_LIST_X (safeZoneX + INFO_LIST_PADDING_X)
#define CONTROLS_LIST_Y (safeZoneY + INFO_LIST_PADDING_Y)

// ...
#define CONTROLS_LIST_WIDTH (0.5 * safeZoneW)
#define CONTROLS_LIST_HEIGHT (0.18 * safeZoneH)

// ...
#define INFO_LIST_BORDER_LEFT_THICKNESS ((1 * pixelW * pixelGridNoUIScale) / 5)
#define INFO_LIST_BORDER_BOTTOM_THICKNESS ((1 * pixelH * pixelGridNoUIScale) / 5)

// ...
#define INFO_LIST_PADDING_X (1 * pixelW * pixelGridNoUIScale)
#define INFO_LIST_PADDING_Y (1 * pixelH * pixelGridNoUIScale)

// ...
#define INFO_LIST_X (safeZoneX + INFO_LIST_PADDING_X)
#define INFO_LIST_Y ((safeZoneY + safeZoneH) - INFO_LIST_HEIGHT - INFO_LIST_PADDING_Y)

// ...
#define INFO_LIST_WIDTH (0.5 * safeZoneW)
#define INFO_LIST_HEIGHT (0.12 * safeZoneH)

// ...
#define N_CONTROLS_LIST_ITEMS (4)
#define CONTROLS_LIST_TEXT_SIZE (0.020 * safeZoneH)

// ...
#define N_INFO_LIST_ITEMS (2)
#define INFO_LIST_TEXT_SIZE (0.030 * safeZoneH)

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

            x = CONTROLS_LIST_X;
            y = CONTROLS_LIST_Y;
            w = CONTROLS_LIST_WIDTH;
            h = CONTROLS_LIST_HEIGHT;

            font = "PuristaMedium";
            sizeEx = CONTROLS_LIST_TEXT_SIZE;

            rowHeight = CONTROLS_LIST_HEIGHT / N_CONTROLS_LIST_ITEMS;
            colorBackground[] = {0, 0, 0, 0};

        };

        class Lock_Outer : RscPictureKeepAspect 
        {

            idc = -1;
            text = "images\lock_outer.paa";

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

        };

        class Lock_Inner : RscPictureKeepAspect 
        {

            idc = 1001;
            text = "images\lock_inner.paa";

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

        };

        class Lock_Pick_Proxy : RscBackground 
        {

            idc = 1003;
            onLoad = "(_this select 0) ctrlShow false";

            text = "";

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

            colorBackground[] = {0, 0, 0, 0};
            
        };

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
            w = (INFO_LIST_WIDTH - INFO_LIST_BORDER_LEFT_THICKNESS) * 0.5;
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

            font = "PuristaSemibold";
            sizeEx = INFO_LIST_TEXT_SIZE;

            rowHeight = INFO_LIST_HEIGHT / N_INFO_LIST_ITEMS;
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

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

        };

        class Lock_Pick : RscPictureKeepAspect
        {

            idc = 1002;
            text = "";

            x = LOCK_PICK_IMAGE_X;
            y = LOCK_PICK_IMAGE_Y;
            w = LOCK_PICK_IMAGE_SIZE_W;
            h = LOCK_PICK_IMAGE_SIZE_H;

        };

        class Lock_Inner_Debug_01 : RscBackground 
        {

            idc = 2001;
            onLoad = "(_this select 0) ctrlShow false";

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

            colorBackground[] = {1, 0, 0, 1};

        };

        class Lock_Inner_Debug_02 : RscBackground 
        {

            idc = 2002;
            onLoad = "(_this select 0) ctrlShow false";

            x = LOCK_IMAGE_X;
            y = LOCK_IMAGE_Y;
            w = LOCK_IMAGE_SIZE_W;
            h = LOCK_IMAGE_SIZE_H;

            colorBackground[] = {1, 0, 0, 1};

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