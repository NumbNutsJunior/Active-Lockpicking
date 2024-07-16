#include "\a3\ui_f\hpp\definedikcodes.inc"
disableSerialization;

// Init event handler parameters and return
params ["_display", "_key_code", "_shift", "_ctrl", "_alt"];
private _handled = false;

// Lockpick minigame
private _hud_lockpick = uiNamespace getVariable ["hud_lockpick", displayNull];
if (!isNull _hud_lockpick) then {_handled = true};

// Case specific
switch (true) do {

    // Debug
    // case (_key_code isEqualTo DIK_Y): {[] spawn pizza_fnc_lockpick};

    // Lockpick mini-game
    case ((!isNull _hud_lockpick) && (_key_code isEqualTo DIK_W)) : {pizza_lockpick_rotate_lock = true};
    case ((!isNull _hud_lockpick) && (pizza_lockpick_rotate_pick isEqualTo 0) && (_key_code isEqualTo DIK_A)) : {pizza_lockpick_rotate_pick = 1};
    case ((!isNull _hud_lockpick) && (pizza_lockpick_rotate_pick isEqualTo 0) && (_key_code isEqualTo DIK_D)) : {pizza_lockpick_rotate_pick = 2};
    case ((!isNull _hud_lockpick) && (_key_code isEqualTo DIK_ESCAPE)) : {("hud_lockpick" call BIS_fnc_rscLayer) cutRsc ["hud_default", "plain"]};
    case ((!isNull _hud_lockpick) && (_key_code in (actionKeys "lookAround")) || (_key_code in (actionKeys "personView"))) : {_handled = false};
};

// Return
_handled;
