
// Config
pizza_inventory_lockpick = 6;

// Setup event handlers
[] call pizza_fnc_initEventhandlers;

// Actions
player addAction ["Lockpick", {[(call pizza_fnc_findTargetSelection) select 0] call pizza_fnc_lockpick}, [], 1, false, true, "", "(((call pizza_fnc_findTargetSelection) select 1) find 'door') >= 0"];