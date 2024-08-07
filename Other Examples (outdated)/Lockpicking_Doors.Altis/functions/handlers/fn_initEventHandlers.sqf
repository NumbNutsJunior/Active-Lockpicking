disableSerialization;

// Wait for main display to load
waitUntil {!isNull (findDisplay 46)};
private _main_display = findDisplay 46;

// Setup key handlers
_main_display displayAddEventHandler ["MouseButtonDown", {_this call pizza_fnc_handler_mousedown}];
_main_display displayAddEventHandler ["KeyDown", {_this call pizza_fnc_handler_keydown}];
_main_display displayAddEventHandler ["KeyUp",   {_this call pizza_fnc_handler_keyup}];

// Scroll-wheel handler
inGameUISetEventHandler ["PrevAction", "_this call pizza_fnc_handler_actions"];
inGameUISetEventHandler ["NextAction", "_this call pizza_fnc_handler_actions"];
inGameUISetEventHandler ["Action", "_this call pizza_fnc_handler_actions"];