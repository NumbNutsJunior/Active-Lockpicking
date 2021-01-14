
// Setup event handlers
[] call pizza_fnc_initEventhandlers;

// Debug
player addAction ["Lockpick", {[cursorObject] call pizza_fnc_lockpick}, [], 1, false, true, "", "(cursorObject isKindOf 'car') && ((locked cursorObject) > 0)"];
