// Author: Pizza Man
// File: fn_formatNumber.sqf
// Description: Takes a number and fills in zeros for missing places.

// Init
params [
    ["_number", 0],
    ["_places", 2]
];

// Figure number of digits and init return
private _digitCount = if ((abs _number) isEqualTo 0) then {1} else {(floor (log (abs _number))) + 1};
private _return = format["%1", _number];

// Add remaining zeros to fill places
for "_i" from 1 to (_places - _digitCount) do {_return = format["0%1", _return]};

// Exit
_return;
