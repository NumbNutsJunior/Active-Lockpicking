disableSerialization;

// Init event handler parameters and return
params ["_display", "_button", "_mouse_pos_x", "_mouse_pos_y", "_shift", "_ctrl", "_alt"];
private _handled = false;

// Lockpick minigame
private _hud_lockpick = uiNamespace getVariable ["hud_lockpick", displayNull];
if (!isNull _hud_lockpick) then {_handled = true};

// Return
_handled;
