
// Config
pizza_inventory_lockpick = 6;

// Setup event handlers
[] call pizza_fnc_initEventhandlers;

// Player actions
player addAction ["Lockpick", {[cursorObject] call pizza_fnc_lockpick}, [], 1, false, true, "", "(cursorObject isKindOf 'car') && ((locked cursorObject) > 0)"];










// Debug
[[screwdriver, car], [1,0,1,1], true] call BIS_fnc_drawBoundingBox;

addMissionEventHandler ["draw3D",
{

	private _center = boundingCenter screwdriver;

	drawIcon3D
	[
		"\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa",
		[1,0,0,1],
		screwdriver modelToWorldVisual _center,
		1,
		1,
		0,
		"",
		0,
		0.04,
		"RobotoCondensed",
		"right",
		true,
		0.005,
		-0.035
	];

}];