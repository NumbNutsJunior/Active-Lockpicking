
/*
    File: fn_hud_lockpick.sqf
    Author: Pizza Man
    Description: A skyrim style lockpicking mini-game.
*/

// ...
disableSerialization;

// Image paths
#define IMAGE_INTACT_LOCKPICK "images\lock_pick.paa"
#define IMAGE_BROKEN_LOCKPICK "images\lock_pick_broken.paa"

// Sound paths
#define SOUND_LOCKPICK_SUCCESS "sound_name"
#define SOUND_LOCKPICK_FAIL "sound_name"

// Create hud and initalize display
"hud_lockpick" cutRsc ["hud_lockpick", "plain"];
private _lock_display = uiNamespace getVariable ["hud_lockpick", displayNull];
if (isNull _lock_display) exitWith {false};

// Create screwdriver display after
"hud_lockpick_screwdriver" cutRsc ["hud_lockpick_screwdriver", "plain"];
private _screw_driver_display = uiNamespace getVariable ["hud_lockpick_screwdriver", displayNull];
if (isNull _screw_driver_display) exitWith {false};

// See below for the details
params [["_difficulty", 3], ["_force_chance", 0.20]];

/*
    Difficulty [sweet spot degress, max unstable duration]:
    1 - Very Easy - [20 degrees, 1.80 seconds]
    2 - Easy      - [16 degrees, 1.60 seconds]
    3 - Normal    - [12 degrees, 1.40 seconds]
    4 - Hard      - [8 degrees,  1.20 seconds]
    5 - Very Hard - [4 degrees,  1.00 seconds]
*/

// Set difficulty settings based on the input
private _difficulty_settings = switch (_difficulty) do {
    case 1: {[20, 1.80]};
    case 2: {[16, 1.60]};
    case 3: {[12, 1.40]};
    case 4: {[8,  1.20]};
    case 5: {[4,  1.00]};
    default {[]};
};

// Check if the difficulty was valid
if ((count _difficulty_settings) isEqualTo 0) exitWith {false};

// Init global variables for mini-game difficulty
pizza_lockpick_sweet_spot_padding = _difficulty_settings select 0;
pizza_lockpick_max_unstable_duration = _difficulty_settings select 1;
pizza_lockpick_force_chance = _force_chance;

// Init global variables for mini-game logic
pizza_lockpick_sweet_spot = (random 180) - 90;
pizza_lockpick_unstable_duration = 0;
pizza_lockpick_rotate_lock = false;
pizza_lockpick_rotate_pick = 0;
pizza_lockpick_picked = nil;

// DEBUG
pizza_lockpick_sweet_spot = -90;

// Lock display controls
private _controls_list = _lock_display displayCtrl 1000;

// Screwdriver display controls
private _screw_driver_object = _screw_driver_display displayCtrl 1000;
private _lock_pick_picture = _screw_driver_display displayCtrl 1002;

// Adjust screwdriver scale regardless of interface size
private _screw_driver_object_scale = 0.55 / (getResolution select 5);
_screw_driver_object ctrlSetModelScale _screw_driver_object_scale;

// Preload images (removes flicker)
_lock_pick_picture ctrlSetText IMAGE_BROKEN_LOCKPICK;
_lock_pick_picture ctrlSetText IMAGE_INTACT_LOCKPICK;

// Populate controls info list
{_controls_list lbAdd (format ["[ %2 ]  %1", _x select 0, _x select 1])} forEach [

    // Controls
    ["Rotate the lock", "W"],
    ["Rotate the pick clockwise", "D"],
    ["Rotate the pick counter-clockwise", "A"],
    [(format ["Force the lock (%1%2 chance)", pizza_lockpick_force_chance * 100, "%"]), "F"]
];

// Blur the background
private _effect_handle = ppEffectCreate ["DynamicBlur", 0];
_effect_handle ppEffectAdjust [2.5];
_effect_handle ppEffectEnable true;
_effect_handle ppEffectCommit 0;

// DEBUG
private _alpha = 0.5;
debug_control_01 = _screw_driver_display ctrlCreate ["Life_RscText", -1];
debug_control_01 ctrlSetPosition [0, 0, 1 * pixelW * pixelGrid, 1 * pixelH * pixelGrid];
debug_control_01 ctrlSetBackgroundColor [1, 0, 0, _alpha];
debug_control_01 ctrlCommit 0;

// DEBUG
debug_control_02 = _screw_driver_display ctrlCreate ["Life_RscText", -1];
debug_control_02 ctrlSetPosition [0, 0, 1 * pixelW * pixelGrid, 1 * pixelH * pixelGrid];
debug_control_02 ctrlSetBackgroundColor [1, 0, 0, _alpha];
debug_control_02 ctrlCommit 0;

// Mini-game logic
["hud_lockpick", "onEachFrame", {

    // Find lock display
    private _lock_display = uiNamespace getVariable ["hud_lockpick", displayNull];
    if (isNull _lock_display) exitWith {pizza_lockpick_picked = false};

    // Find screwdriver display
    private _screw_driver_display = uiNamespace getVariable ["hud_lockpick_screwdriver", displayNull];
    if (isNull _screw_driver_display) exitWith {pizza_lockpick_picked = false};

    // Lock display controls
    private _lock_inner_picture = _lock_display displayCtrl 1001;
    private _lock_pick_proxy = _lock_display displayCtrl 1003;

    // Screwdriver display controls
    private _screw_driver_object = _screw_driver_display displayCtrl 1000;
    private _lock_pick_picture = _screw_driver_display displayCtrl 1002;
    private _lock_inner_shadow = _screw_driver_display displayCtrl 1003;

    // Mini-game completed
    if (!isNil "pizza_lockpick_picked") exitWith {

        // Visually update lockpick based on pick success 
        _lock_pick_picture ctrlSetText ([IMAGE_BROKEN_LOCKPICK, IMAGE_INTACT_LOCKPICK] select pizza_lockpick_picked);

        // Play sound based on pick success
        // playSound ([SOUND_LOCKPICK_FAIL, SOUND_LOCKPICK_SUCCESS] select pizza_lockpick_picked);

        // Stop mini-game logic
        ["hud_lockpick", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

    };

    // Init basic info
    private _rotation_speed = 0.8; // Seconds
    private _rotation_amount = 90; // Degrees
    private _lockpick_shake_amount = 1; // Degrees
    private _delta = diag_deltaTime; // Seconds

    call {

        // Calculate the current angle of the inner lock and ensure it's within 0-359 degrees
        private _current_lock_angle = ((ctrlAngle _lock_inner_picture) select 0) % 360;

        // Determine the angle change for the lock based on rotation amount, time delta, and rotation speed...
        // the lock rotates counter-clockwise unless the lock is set to rotate, so the angle change is negative
        private _next_lock_angle_difference = -(_rotation_amount * (_delta / _rotation_speed));

        // If the lock is supposed to rotate, ensure the angle difference is positive
        if (pizza_lockpick_rotate_lock) then {_next_lock_angle_difference = abs _next_lock_angle_difference};

        // Calculate the next angle for the lock by adding the difference to the current angle
        private _next_lock_angle = (_current_lock_angle + _next_lock_angle_difference) % 360;

        // Calculate the current angle of the lockpick and ensure it's within 0-359 degrees
        private _pick_current_angle = ((ctrlAngle _lock_pick_proxy) select 0) % 360;

        // Calculate the padding for the sweet spot based on the lockpick's difficulty
        private _sweet_spot_padding = [pizza_lockpick_sweet_spot - (pizza_lockpick_sweet_spot_padding / 2), pizza_lockpick_sweet_spot + (pizza_lockpick_sweet_spot_padding / 2)];

        // Calculate the distance to the sweet spot
        _distance_to_sweet_spot = abs (_pick_current_angle - pizza_lockpick_sweet_spot);

        // If the pick is within the sweet spot, set distance to 0
        if ((_pick_current_angle >= (_sweet_spot_padding select 0)) && (_pick_current_angle <= (_sweet_spot_padding select 1))) then {_distance_to_sweet_spot = 0};

        // Calculate the maximum rotation percentage based on distance to sweet spot
        private _max_lock_roation_percentage = abs (1 - (_distance_to_sweet_spot / 180));

        // Calculate the actual maximum rotation allowed
        private _max_lock_roation = _rotation_amount * _max_lock_roation_percentage;

        // Ensure the next lock angle does not exceed the maximum allowed rotation
        _next_lock_angle = (_next_lock_angle max 0) min _max_lock_roation;

        call {

            // Get the center of the inner lock picture
            (ctrlPosition _lock_inner_picture) params ["_lock_inner_x", "_lock_inner_y", "_lock_inner_w", "_lock_inner_h"];
            [0.500, 0.485] params ["_lock_center_x_relative", "_lock_center_y_relative"];
            private _lock_center_x = _lock_inner_x + (_lock_inner_w * _lock_center_x_relative);
            private _lock_center_y = _lock_inner_y + (_lock_inner_h * _lock_center_y_relative);

            // Apply the calculated rotation to the inner lock
            _lock_inner_picture ctrlSetAngle [_next_lock_angle, _lock_center_x_relative, _lock_center_y_relative, true];
            _lock_inner_shadow ctrlSetAngle [_next_lock_angle, _lock_center_x_relative, _lock_center_y_relative, true];

            // Calculate the offset for the lockpick based on the current angle
            private _lock_pick_offset_radius_x = 0.50 * (pixelW * pixelGridNoUIScale);
            private _lock_pick_offset_radius_y = 0.90 * (pixelH * pixelGridNoUIScale);
            private _lock_pick_offset_x = - (((sin _next_lock_angle) * _lock_pick_offset_radius_x));
            private _lock_pick_offset_y =   (((cos _next_lock_angle) * _lock_pick_offset_radius_y));

            // Update the lockpick's position based on the calculated offsets
            (ctrlPosition _lock_pick_picture) params ["_", "_", "_pick_pos_w", "_pick_pos_h"];
            _lock_pick_picture ctrlSetPositionX (_lock_pick_offset_x + ((_lock_center_x - (_pick_pos_w / 2)) - ((pixelW * pixelGridNoUIScale) * 0.20)));
            _lock_pick_picture ctrlSetPositionY (_lock_pick_offset_y + ((_lock_center_y - (_pick_pos_h / 2)) + ((pixelH * pixelGridNoUIScale) * 0.60)));
            _lock_pick_picture ctrlCommit 0;

            // Calculate the position where the screwdriver should point
            private _screw_driver_tip_offset_radius_x = 3.75 * (pixelW * pixelGridNoUIScale);
            private _screw_driver_tip_offset_radius_y = 3.75 * (pixelH * pixelGridNoUIScale);
            private _screw_driver_tip_offset_x = - ((sin _next_lock_angle) * _screw_driver_tip_offset_radius_x);
            private _screw_driver_tip_offset_y =   ((cos _next_lock_angle) * _screw_driver_tip_offset_radius_y);
            private _screw_driver_tip_position_x = _lock_center_x + _screw_driver_tip_offset_x - ((pixelW * pixelGridNoUIScale) * 0.20);
            private _screw_driver_tip_position_y = _lock_center_y + _screw_driver_tip_offset_y;
            private _screw_driver_tip_position_z = 0;

            // Calculate the position of the screwdriver based on the tip position
            private _screw_driver_position_x = _screw_driver_tip_position_x + (safeZoneW * 0.10);
            private _screw_driver_position_y = _screw_driver_tip_position_y + (safeZoneH * 0.10);
            private _screw_driver_position_z = 0.25;

            // DEBUG
            debug_control_01 ctrlSetPosition [_screw_driver_tip_position_x, _screw_driver_tip_position_y];
            debug_control_01 ctrlCommit 0;

            // DEBUG
            debug_control_02 ctrlSetPosition [_screw_driver_position_x, _screw_driver_position_y];
            debug_control_02 ctrlCommit 0;

            // Get the screwdriver's current position and desired tip position
            private _screw_driver_position = [_screw_driver_position_x, _screw_driver_position_z, _screw_driver_position_y];
            private _screw_driver_tip_position = [_screw_driver_tip_position_x, _screw_driver_tip_position_z, _screw_driver_tip_position_y];

            // Update the screwdriver's position
            _screw_driver_object ctrlSetPosition _screw_driver_position;

            // Arma GUI object uses a different coordinate system, so the Z and Y values are swapped
            _screw_driver_position = [_screw_driver_position_x, _screw_driver_position_y, _screw_driver_position_z];
            _screw_driver_tip_position = [_screw_driver_tip_position_x, _screw_driver_tip_position_y, _screw_driver_tip_position_z];

            // Calculate the screwdriver's direction based on the tip position
            private _screw_driver_dir = _screw_driver_position vectorFromTo _screw_driver_tip_position;

            // ...
            private _random_direction = [random 100, random 100, random 100];
            _random_direction = vectorNormalized _random_direction;

            // ...
            private _screw_driver_up = _screw_driver_dir vectorCrossProduct _random_direction;
            _screw_driver_up = vectorNormalized _screw_driver_up;

            /*
            // Set the limits for the screwdriver's rotation based on the lock's rotation
            private _screw_driver_rotated_up_vector = if (_next_lock_angle isEqualTo _max_lock_roation) then [{_screw_driver_up}, {[_screw_driver_up, -_next_lock_angle_difference, 1] call BIS_fnc_rotateVector3D}];
            if (_current_lock_angle isEqualTo 0) then {_screw_driver_rotated_up_vector = [-1, -1, 0]};
            */

            // Update the screwdriver's direction
            _screw_driver_object ctrlSetModelDirAndUp [_screw_driver_dir, _screw_driver_up];
            
        };

        // Check if the lock has been successfully picked
        if (_next_lock_angle isEqualTo 90) exitWith {pizza_lockpick_picked = true};

        // Check if the lockpick is in the unstable region
        if ((_current_lock_angle isEqualTo _max_lock_roation) && pizza_lockpick_rotate_lock) then {

            // Simulate lockpick shaking by adjusting its angle randomly within a range
            _lock_pick_picture ctrlSetAngle [_pick_current_angle + ((random (_lockpick_shake_amount * 2)) - _lockpick_shake_amount), 0.5, 0.4875, true];

            // Increase the duration the lockpick has been unstable if it's supposed to rotate
            if (pizza_lockpick_rotate_lock) then {pizza_lockpick_unstable_duration = pizza_lockpick_unstable_duration + _delta};

            // Check if the lockpick has been unstable for too long and break it
            if (pizza_lockpick_unstable_duration >= pizza_lockpick_max_unstable_duration) exitWith {pizza_lockpick_picked = false};

        } else {

            // Reset the lockpick's angle and unstable duration if it's stable
            _lock_pick_picture ctrlSetAngle [_pick_current_angle, 0.5, 0.4875, true];
            pizza_lockpick_unstable_duration = 0;

        };

    };

    call {

        // Only proceed if the lock is not set to rotate
        if !(pizza_lockpick_rotate_lock) then {

            // Check if there's a need to rotate the lockpick
            if !(pizza_lockpick_rotate_pick isEqualTo 0) then {

                // Calculate the current angle of the lockpick
                private _pick_current_angle = ((ctrlAngle _lock_pick_picture) select 0) % 360;

                // Determine the angle change for the lockpick based on rotation amount, time delta, and rotation speed
                // the lockpick rotates counter-clockwise unless the lockpick is set to rotate clockwise, so the angle change is negative
                private _next_angle_difference = -(_rotation_amount * (_delta / _rotation_speed));

                // If the lockpick is set to rotate in a specific direction, make the angle difference positive
                if (pizza_lockpick_rotate_pick isEqualTo 2) then {_next_angle_difference = abs _next_angle_difference};

                // Calculate the next angle for the lockpick
                private _next_angle = (_pick_current_angle + _next_angle_difference) % 360;

                // Ensure the next angle does not exceed the limits
                _next_angle = (_next_angle min 90) max -90;

                // Apply the calculated rotation to the lockpick and its proxy
                _lock_pick_picture ctrlSetAngle [_next_angle, 0.5, 0.4875, true];
                _lock_pick_proxy ctrlSetAngle [_next_angle, 0.5, 0.5, true];
                
            };

        };

    };

}] call BIS_fnc_addStackedEventHandler;

// Cleanup mini-game
_lock_display displayAddEventHandler ["Unload", {

    // Delete global variables for mini-game difficulty
    pizza_lockpick_sweet_spot_padding = nil;
    pizza_lockpick_unstable_lock_percent = nil;
    pizza_lockpick_max_unstable_duration = nil;
    pizza_lockpick_force_chance = nil;

    // Delete global variables for mini-game logic
    pizza_lockpick_sweet_spot = nil;
    pizza_lockpick_unstable_duration = nil;
    pizza_lockpick_rotate_lock = nil;
    pizza_lockpick_rotate_pick = nil;

    // Stop mini-game logic
    ["hud_lockpick", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
    
    // Remove the screwdriver display
    "hud_lockpick_screwdriver" cutRsc ["hud_default", "plain"];

}];

// Wait until mini-game is complete
waitUntil {(!isNil "pizza_lockpick_picked") || (isNull _lock_display)};

// Check if the mini-game was closed early
if (!isNull _lock_display) then {

    // Wait a second for sounds/animations to finish
    uiSleep 1;

    // Cleanup mini-game display
    "hud_lockpick" cutRsc ["hud_default", "plain"];

};

// Remove background blur
_effect_handle ppEffectEnable false;
ppEffectDestroy _effect_handle;

// Get the return value of the mini-game
private _return = missionNamespace getVariable ["pizza_lockpick_picked", false];
pizza_lockpick_picked = nil;

// Return
_return;
