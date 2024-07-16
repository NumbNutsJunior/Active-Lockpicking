
// Script parameters
params [["_lockpick_target", objNull]];

// Attempt to lockpick
private _picked = [] call pizza_fnc_hud_lockpick;

// Lockpicked failed
if !(_picked) exitWith {

    // Inform user and return false
    titleText ["You have failed to pick the lock", "plain"];
    false;
};

// Case specific
switch (true) do {

    // Houses
    case (_lockpick_target isKindOf "house"): {

        // Current target selection
        private _target_selection = call pizza_fnc_findTargetSelection;
        _target_selection params ["_parent_object", "_selection", "_selection_position"];
        if !(_selection in (selectionNames _parent_object)) exitWith {};
        
        // Find animation name for given selection
        private _animation_names = animationNames _parent_object;
        private _animation_index = _animation_names findIf {!((_x find _selection) isEqualTo -1)};
        if (_animation_index isEqualTo -1) exitWith {};

        // Check if door is locked
        if ((_parent_object getVariable [(format ["bis_disabled_%1", _selection]), 0]) isEqualTo 1) then {

            // Unlock and open the door
            _parent_object animate [_animation_names select _animation_index, 1, 1];
            _parent_object setVariable [format ["bis_disabled_%1", _selection], 0, true];
            titleText ["The door has been lockpicked", "plain"]; 
        } else {

            // Lock and close the door (doesnt really make sense but just for fun)
            _parent_object animate [_animation_names select _animation_index, 0, 1];
            _parent_object setVariable [format ["bis_disabled_%1", _selection], 1, true];
            titleText ["The door has been anti-lockpicked", "plain"]; 
        }; 
    };

    // None
    default {};
};

// Return
_picked;