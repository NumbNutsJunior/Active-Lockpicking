
// Init event handler parameters and return
params ["_target", "_caller", "_actionID", "_nameEngine", "_nameUser", "_priority", "_showWindow", "_hideOnUse", "_shortcut", "_isActionMenuVisible", "_eventName"];
private _handled = false;

// Lockpick minigame
private _hud_lockpick = uiNamespace getVariable ["hud_lockpick", displayNull];
if (!isNull _hud_lockpick) then {_handled = true};

// Return
_handled;