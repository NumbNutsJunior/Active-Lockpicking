#include "\a3\ui_f\hpp\definedikcodes.inc"
disableSerialization;

// Init event handler parameters and return
params ["_display", "_key_code", "_shift", "_ctrl", "_alt"];
private _handled = false;

// HUD displays
private _hud_lockpick = uiNamespace getVariable ["hud_lockpick", displayNull];
if (!isNull _hud_lockpick) then {_handled = true};

// Case specific
switch (true) do {

    // Lockpick mini-game
    case ((!isNull _hud_lockpick) && (_key_code isEqualTo DIK_W)) : {pizza_lockpick_rotate_lock = false};
    case ((!isNull _hud_lockpick) && (_key_code isEqualTo DIK_A)) : {pizza_lockpick_rotate_pick = 0};
    case ((!isNull _hud_lockpick) && (_key_code isEqualTo DIK_D)) : {pizza_lockpick_rotate_pick = 0};
    case ((!isNull _hud_lockpick) && (_key_code in (actionKeys "lookAround")) || (_key_code in (actionKeys "personView"))) : {_handled = false};
};

// Return
_handled;
