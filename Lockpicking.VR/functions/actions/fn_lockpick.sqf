
// Script parameters
params [["_lockpick_target", objNull]];

// Attempt to lockpick
private _picked = [5] call pizza_fnc_hud_lockpick;

// Lockpicked failed
if !(_picked) exitWith {

    // Inform user and return false
    titleText ["You have failed to pick the lock", "plain"];
    uiSleep 2;
    titleText ["", "plain"];

    // Return
    false;
};

// Case specific
switch (true) do {

    // Vehicles
    case (_lockpick_target isKindOf "car"): {

        // Unlock the car
        _lockpick_target lock false;
        titleText ["The vehicle has been lockpicked", "plain"]; 
        uiSleep 2;
        titleText ["", "plain"];

    };

    // None
    default {};
};

// Return
_picked;