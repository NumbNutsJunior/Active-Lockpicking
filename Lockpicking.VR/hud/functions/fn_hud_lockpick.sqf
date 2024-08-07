
/*
    File: fn_hud_lockpick.sqf
    Author: Pizza Man
    Sound design: "Sikorsky" & "Lil Unemployed (lockpicked local McDonalds)"
    Description: A fallout style lockpicking mini-game.
*/

// ...
disableSerialization;

// Image paths
#define IMAGE_INTACT_LOCKPICK "images\lock_pick.paa"
#define IMAGE_BROKEN_LOCKPICK "images\lock_pick_broken.paa"

// Sounds
#define SOUND_LOCKPICK_SUCCESS "unlock"
#define SOUND_LOCKPICK_FAIL_NORMAL "lockpick_break"
#define SOUND_LOCKPICK_FAIL_CHANCE "lockpick_break_chance"
#define SOUND_LOCKPICK_JIGGLE "lockpick_jiggle"
#define SOUND_INNER_LOCK_RATTLE "lockpick_rattle"
#define SOUND_INNER_LOCK_ROTATE "lockpick_inner_lock_rotate"

// See below for the difficulty details
params [["_difficulty_level", 0], ["_force_lock_settings", [0.20, 5]], ["_sweet_spot", (random 180) - 90]];

/*

    Difficulty [sweet spot degress, max unstable duration]:
    0 - Average   - [6 degrees,  2.00 seconds]
    1 - Hard      - [4 degrees,  1.75 seconds]
    2 - Very Hard - [2 degrees,  1.50 seconds]
    3 - Expert    - [1 degrees,  1.25 seconds]

    Force Lock Settings [force chance, force duration]

*/

// Set difficulty settings based on the input
private _difficulty_config = switch (_difficulty_level) do
{
    case 0: {["Average",    [6, 2.00]]};
    case 1: {["Hard",       [4, 1.75]]};
    case 2: {["Very Hard",  [2, 1.50]]};
    case 3: {["Expert",     [1, 1.25]]};
    default {[]};
};

// Check if the difficulty level is valid
if ((count _difficulty_config) isEqualTo 0) exitWith {false};

// Difficulty text and settings
_difficulty_config params ["_difficulty_text", "_difficulty_settings"];

// Force lock settings
_force_lock_settings params ["_force_chance", "_force_duration"];

// Check if the force settings are valid
if ((_force_chance < 0) || (_force_chance > 1)) exitWith {false};
if (_force_duration < 0) exitWith {false};

// Check if the sweetspot is valid
if ((abs _sweet_spot) > 90) exitWith {false};

// Create hud and initalize display
"hud_lockpick" cutRsc ["hud_lockpick", "plain"];
private _lock_display = uiNamespace getVariable ["hud_lockpick", displayNull];
if (isNull _lock_display) exitWith {false};

// Create screwdriver display after
"hud_lockpick_screwdriver" cutRsc ["hud_lockpick_screwdriver", "plain"];
private _screw_driver_display = uiNamespace getVariable ["hud_lockpick_screwdriver", displayNull];
if (isNull _screw_driver_display) exitWith {false};


// Init global variables for mini-game difficulty
pizza_lockpick_sweet_spot_padding = _difficulty_settings select 0;
pizza_lockpick_max_unstable_duration = _difficulty_settings select 1;
pizza_lockpick_force_chance = _force_chance;
pizza_lockpick_force_duration = _force_duration;

// ...
pizza_lockpick_forced = false;
pizza_lockpick_forced_key_flag = false;

// Sound ids
// [rotate lockpick, rotate lock, lockpick shake]
pizza_lockpick_sounds = [-1, -1, -1];

// Init global variables for mini-game logic
pizza_lockpick_sweet_spot = _sweet_spot;
pizza_lockpick_unstable_duration = 0;
pizza_lockpick_rotate_lock = false;
pizza_lockpick_rotate_pick = 0;
pizza_lockpick_picked = nil;

// Lock display controls and info list
private _controls_list = _lock_display displayCtrl 1000;
private _info_list = _lock_display displayCtrl 1004;

// Screwdriver display controls
private _screw_driver_object = _screw_driver_display displayCtrl 1000;
private _lock_pick_picture = _screw_driver_display displayCtrl 1002;

// Resolution data
getResolution params ["_screen_w", "_screen_h", "_", "_", "_aspect_ratio", "_ui_scale"];

// Adjust screwdriver scale regardless of interface size
private _screw_driver_object_scale = (0.55 / _ui_scale);
_screw_driver_object ctrlSetModelScale _screw_driver_object_scale;

// Temporary fix for the screwdriver's direction
_screw_driver_object ctrlShow ((_screen_w isEqualTo 1920) && {(_screen_h isEqualTo 1080)} && {(_aspect_ratio toFixed 3) isEqualTo ((16 / 9) toFixed 3)});

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

// Populate info list
{_info_list lbAdd _x} forEach [

    // Info
    format ["Difficulty: %1", _difficulty_text],
    format ["Lockpicks remaining: %1", [pizza_inventory_lockpick] call pizza_fnc_format_number]
];

// Blur the background
private _effect_handle = ppEffectCreate ["DynamicBlur", 0];
_effect_handle ppEffectAdjust [2.5];
_effect_handle ppEffectEnable true;
_effect_handle ppEffectCommit 0;

// Mini-game logic
["hud_lockpick", "onEachFrame", 
{

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
    if (!isNil "pizza_lockpick_picked") exitWith 
    {

        {

            // ...
            stopSound _x;
            pizza_lockpick_sounds set [_forEachIndex, -1];

        // Stop and reset the all the sounds
        } forEach (pizza_lockpick_sounds select {_x isNotEqualTo -1});

        // Visually update lockpick based on pick success 
        _lock_pick_picture ctrlSetText ([IMAGE_BROKEN_LOCKPICK, IMAGE_INTACT_LOCKPICK] select pizza_lockpick_picked);

        // ...
        private _lock_pick_east_egg_chance = 300;

        // Check if the lockpickign was sucessful
        private _lock_pick_end_sound = if (pizza_lockpick_picked) then 
        [
            {SOUND_LOCKPICK_SUCCESS}, 
            {[SOUND_LOCKPICK_FAIL_NORMAL, SOUND_LOCKPICK_FAIL_CHANCE] select ((ceil (random _lock_pick_east_egg_chance)) isEqualTo 1)}
        ];

        // Play sound based on pick success
        playSoundUI [_lock_pick_end_sound, 1];

        // Stop mini-game logic
        ["hud_lockpick", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

    };

    // Init basic mini-game info
    private _lock_pick_rotation_speed = 2.00; // Seconds
    private _inner_lock_rotation_speed = 0.75; // Seconds
    private _inner_lock_rotation_amount = 90; // Degrees
    private _lock_pick_shake_amount = 1; // Degrees
    private _delta = diag_deltaTime; // Seconds

    call 
    {

        // Calculate the current angle of the inner lock and ensure it's within 0-359 degrees
        private _current_lock_angle = ((ctrlAngle _lock_inner_picture) select 0) % 360;

        // Check if the lock was forced while being rotated
        if (pizza_lockpick_forced_key_flag && !pizza_lockpick_forced && (_current_lock_angle isNotEqualTo 0)) then 
        {

            // Inform the user they cannot force the lock while the lock is rotating

            // Reset forced variable
            pizza_lockpick_forced_key_flag = false;

        };

        // Check if the lock was forced
        if (pizza_lockpick_forced_key_flag) then 
        {

            // Update the lock's rotation speed and force the lock
            _inner_lock_rotation_speed = pizza_lockpick_force_duration;
            pizza_lockpick_forced = true;

        };

        // Determine the angle change for the lock based on rotation amount, time delta, and rotation speed...
        // the lock rotates counter-clockwise unless the lock is set to rotate, so the angle change is negative
        private _next_lock_angle_difference = -(_inner_lock_rotation_amount * (_delta / _inner_lock_rotation_speed));

        // If the lock is supposed to rotate, ensure the angle difference is positive
        if (pizza_lockpick_rotate_lock || pizza_lockpick_forced) then {_next_lock_angle_difference = abs _next_lock_angle_difference};

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
        private _max_lock_roation_percentage = if (pizza_lockpick_forced) then [{1}, {abs (1 - (_distance_to_sweet_spot / 180))}];

        // Calculate the actual maximum rotation allowed
        private _max_lock_roation = _inner_lock_rotation_amount * _max_lock_roation_percentage;

        // Ensure the next lock angle does not exceed the maximum allowed rotation
        _next_lock_angle = (_next_lock_angle max 0) min _max_lock_roation;

        // Get the center of the inner lock picture
        (ctrlPosition _lock_inner_picture) params ["_lock_inner_x", "_lock_inner_y", "_lock_inner_w", "_lock_inner_h"];
        [0.5, 0.5 - (0.5 * (pixelH * pixelGridNoUIScale))] params ["_lock_center_x_relative", "_lock_center_y_relative"];
        private _lock_center_x = _lock_inner_x + (_lock_inner_w * _lock_center_x_relative);
        private _lock_center_y = _lock_inner_y + (_lock_inner_h * _lock_center_y_relative);

        // Apply the calculated rotation to the inner lock
        _lock_inner_picture ctrlSetAngle [_next_lock_angle, _lock_center_x_relative, _lock_center_y_relative, true];
        _lock_inner_shadow ctrlSetAngle [_next_lock_angle, _lock_center_x_relative, _lock_center_y_relative, true];

        // Calculate the offset for the lockpick based on the current angle
        private _lock_pick_offset_radius_x = 1 * (pixelW * pixelGridNoUIScale);
        private _lock_pick_offset_radius_y = 1 * (pixelH * pixelGridNoUIScale);
        private _lock_pick_offset_x = - (((sin _next_lock_angle) * _lock_pick_offset_radius_x));
        private _lock_pick_offset_y =   (((cos _next_lock_angle) * _lock_pick_offset_radius_y));

        // Update the lockpick's position based on the calculated offsets
        (ctrlPosition _lock_pick_picture) params ["_", "_", "_pick_pos_w", "_pick_pos_h"];
        _lock_pick_picture ctrlSetPositionX ((_lock_center_x - (_pick_pos_w / 2)) + _lock_pick_offset_x);
        _lock_pick_picture ctrlSetPositionY ((_lock_center_y - (_pick_pos_h / 2)) + _lock_pick_offset_y);
        _lock_pick_picture ctrlCommit 0;

        call 
        {

            // Calculate the position where the screwdriver should point
            private _screw_driver_tip_offset_x = - (sin _next_lock_angle) * (((_lock_inner_w / 2) * 0.6) - (4.75 * (pixelW * pixelGridNoUIScale)));
            private _screw_driver_tip_offset_y =   (cos _next_lock_angle) * (((_lock_inner_h / 2) * 0.6) - (4.75 * (pixelH * pixelGridNoUIScale)));
            private _screw_driver_tip_position_x = _lock_center_x + _screw_driver_tip_offset_x - (0.25 * (pixelW * pixelGridNoUIScale));
            private _screw_driver_tip_position_y = _lock_center_y + _screw_driver_tip_offset_y - (0.25 * (pixelH * pixelGridNoUIScale));
            private _screw_driver_tip_position_z = 0;

            // DEBUG
            private _debug_control_01 = _screw_driver_display displayCtrl 2001;
            _debug_control_01 ctrlSetPosition [_screw_driver_tip_position_x, _screw_driver_tip_position_y, pixelW * 5, pixelH * 5];
            _debug_control_01 ctrlCommit 0;

            // Define screen space coordinates and desired z-depth
            private _screw_driver_position_offset_x = 10 * (pixelW * pixelGridNoUIScale);
            private _screw_driver_position_offset_y = 10 * (pixelH * pixelGridNoUIScale);
            private _screw_driver_position_x = _screw_driver_tip_position_x + _screw_driver_position_offset_x;
            private _screw_driver_position_y = _screw_driver_tip_position_y + _screw_driver_position_offset_y;
            private _screw_driver_position_z = 0.25;

            // DEBUG
            private _debug_control_02 = _screw_driver_display displayCtrl 2002;
            _debug_control_02 ctrlSetPosition [_screw_driver_position_x, _screw_driver_position_y, pixelW * 5, pixelH * 5];
            _debug_control_02 ctrlCommit 0;

            // Get the screwdriver's current position and desired tip position
            private _screw_driver_position = [_screw_driver_position_x, _screw_driver_position_z, _screw_driver_position_y];
            private _screw_driver_tip_position = [_screw_driver_tip_position_x, _screw_driver_tip_position_z, _screw_driver_tip_position_y];

            // Update the screwdriver's position and the screwdriver tip's position
            _screw_driver_object ctrlSetPosition _screw_driver_position;

            // Swap the y and z coordinates for the screwdriver's position and tip position
            _screw_driver_position = [_screw_driver_position select 0, _screw_driver_position select 2, _screw_driver_position select 1];
            _screw_driver_tip_position = [_screw_driver_tip_position select 0, _screw_driver_tip_position select 2, _screw_driver_tip_position select 1];

            // Adjust the tip position (fix until https://community.bistudio.com/wiki/screenToWorldDirection)
            _screw_driver_tip_position set [2, (_screw_driver_tip_position select 2) + (2 * (pixelH * pixelGridNoUIScale))];

            // Calculate the screwdriver's direction based on the tip position
            private _screw_driver_dir = _screw_driver_position vectorFromTo _screw_driver_tip_position;
            _screw_driver_dir set [1, -(_screw_driver_dir select 1)];
            _screw_driver_dir set [2, -(_screw_driver_dir select 2)];

            // Calculate the direction perpendicular to the inner lock's angle
            private _lock_inner_perpendicular_angle = _current_lock_angle + 90;
            private _lock_inner_perpendicular_dir = [-cos _lock_inner_perpendicular_angle, 0, sin _lock_inner_perpendicular_angle];
            
            // ...
            private _screw_driver_up = _lock_inner_perpendicular_dir vectorCrossProduct _screw_driver_dir;
            _screw_driver_up = vectorNormalized _screw_driver_up;

            // Update the screwdriver's direction
            _screw_driver_object ctrlSetModelDirAndUp [_screw_driver_dir, _screw_driver_up];
            
        };

        call
        {

            // Check if the lock is supposed to rotate
            if ((_current_lock_angle isNotEqualTo 0) && ((_current_lock_angle toFixed 2) isNotEqualTo (_max_lock_roation toFixed 2))) then 
            {

                // Check to play lock rotation sound
                if ((pizza_lockpick_sounds select 1) isEqualTo -1) then 
                {

                    // ...
                    pizza_lockpick_sounds set [1, playSoundUI [SOUND_INNER_LOCK_ROTATE, 0.5]];

                }
                else
                {

                   // Check if the sound has finished playing
                    if ((count (soundParams (pizza_lockpick_sounds select 1))) isEqualTo 0) then
                    {

                        // Stop and reset the sound
                        stopSound (pizza_lockpick_sounds select 1);
                        pizza_lockpick_sounds set [1, -1];

                    };

                };

            }
            else
            {

                // Check to stop lock rotation sound
                if ((pizza_lockpick_sounds select 1) isNotEqualTo -1) then 
                {

                    // Stop and reset the sound
                    stopSound (pizza_lockpick_sounds select 1);
                    pizza_lockpick_sounds set [1, -1];

                };

            };

        };

        call 
        {

            // Check if the lock has been successfully picked
            private _inner_lock_fully_rotated = (_current_lock_angle toFixed 2) isEqualTo (90 toFixed 2);
            if (_inner_lock_fully_rotated && !pizza_lockpick_forced) exitWith {pizza_lockpick_picked = true};
            if (_inner_lock_fully_rotated && pizza_lockpick_forced) exitWith {pizza_lockpick_picked = (random 1) <= pizza_lockpick_force_chance};

            // Check if the lockpick is in the unstable region
            if (((_current_lock_angle toFixed 2) isEqualTo (_max_lock_roation toFixed 2)) && pizza_lockpick_rotate_lock && !pizza_lockpick_forced) then 
            {

                // Check to play lock rattle sound
                if ((pizza_lockpick_sounds select 2) isEqualTo -1) then 
                {

                    // ...
                    pizza_lockpick_sounds set [2, playSoundUI [SOUND_INNER_LOCK_RATTLE, 1]];

                }
                else
                {

                    // Check if the sound has finished playing
                    if ((count (soundParams (pizza_lockpick_sounds select 2))) isEqualTo 0) then
                    {

                        // Stop and reset the sound
                        stopSound (pizza_lockpick_sounds select 2);
                        pizza_lockpick_sounds set [2, -1];

                    };

                };

                // Simulate lockpick shaking by adjusting its angle randomly within a range
                _lock_pick_picture ctrlSetAngle [_pick_current_angle + ((random (_lock_pick_shake_amount * 2)) - _lock_pick_shake_amount), 0.5, 0.5, true];

                // Increase the duration the lockpick has been unstable if it's supposed to rotate
                pizza_lockpick_unstable_duration = pizza_lockpick_unstable_duration + _delta;

                // Check if the lockpick has been unstable for too long and break it
                if (pizza_lockpick_unstable_duration >= pizza_lockpick_max_unstable_duration) exitWith {pizza_lockpick_picked = false};

            } else {

                // Check to play lock rattle sound
                if ((pizza_lockpick_sounds select 2) isNotEqualTo -1) then 
                {

                    // Stop and reset the sound
                    stopSound (pizza_lockpick_sounds select 2);
                    pizza_lockpick_sounds set [2, -1];

                };

                // Reset the lockpick's angle if it's stable
                _lock_pick_picture ctrlSetAngle [_pick_current_angle, 0.5, 0.5, true];

                // Reset the unstable duration if the lock is stable
                // pizza_lockpick_unstable_duration = 0;

            };

        };

        call 
        {

            // Only proceed if the lock is not set to rotate
            if (!pizza_lockpick_rotate_lock && !pizza_lockpick_forced) then 
            {

                // ...
                private _pick_current_angle = ((ctrlAngle _lock_pick_picture) select 0) % 360;
                private _lockpick_not_at_edge = (round (abs _pick_current_angle)) isNotEqualTo 90;

                // Check if there's a need to rotate the lockpick
                if (pizza_lockpick_rotate_pick isNotEqualTo 0) then
                {

                    // Check to play jiggle sound
                    if (((pizza_lockpick_sounds select 0) isEqualTo -1) && (_lockpick_not_at_edge)) then 
                    {

                        // ...
                        pizza_lockpick_sounds set [0, playSoundUI [SOUND_LOCKPICK_JIGGLE, 0.5]];

                    };

                    // Stop the sound if lockpick at the edge
                    if (((pizza_lockpick_sounds select 0) isNotEqualTo -1) && (!_lockpick_not_at_edge)) then 
                    {

                        // Stop and reset the sound
                        stopSound (pizza_lockpick_sounds select 0);
                        pizza_lockpick_sounds set [0, -1];

                    };

                    // Determine the angle change for the lockpick based on rotation amount, time delta, and rotation speed
                    // the lockpick rotates counter-clockwise unless the lockpick is set to rotate clockwise, so the angle change is negative
                    private _next_angle_difference = -(180 * (_delta / _lock_pick_rotation_speed));

                    // If the lockpick is set to rotate in a specific direction, make the angle difference positive
                    if (pizza_lockpick_rotate_pick isEqualTo 2) then {_next_angle_difference = abs _next_angle_difference};

                    // Calculate the next angle for the lockpick
                    private _next_angle = (_pick_current_angle + _next_angle_difference) % 360;

                    // Ensure the next angle does not exceed the limits
                    _next_angle = (_next_angle min 90) max -90;

                    // Apply the calculated rotation to the lockpick and its proxy
                    _lock_pick_picture ctrlSetAngle [_next_angle, 0.5, 0.5, true];
                    _lock_pick_proxy ctrlSetAngle [_next_angle, 0.5, 0.5, true];
                    
                }
                else 
                {

                    // Check to stop the jiggle sound
                    if ((pizza_lockpick_sounds select 0) isNotEqualTo -1) then 
                    {

                        // Stop and reset the sound
                        stopSound (pizza_lockpick_sounds select 0);
                        pizza_lockpick_sounds set [0, -1];

                    };

                };

            }
            else
            {

                // Check to stop the jiggle sound
                if ((pizza_lockpick_sounds select 0) isNotEqualTo -1) then 
                {

                    // Stop and reset the sound
                    stopSound (pizza_lockpick_sounds select 0);
                    pizza_lockpick_sounds set [0, -1];

                };

            };

        };

    };

}] call BIS_fnc_addStackedEventHandler;

// Cleanup mini-game
_lock_display displayAddEventHandler ["Unload", 
{

    // Delete global variables for mini-game difficulty
    pizza_lockpick_sweet_spot_padding = nil;
    pizza_lockpick_unstable_lock_percent = nil;
    pizza_lockpick_max_unstable_duration = nil;
    pizza_lockpick_force_chance = nil;
    pizza_lockpick_force_duration = nil;

    // ...
    pizza_lockpick_forced = nil;
    pizza_lockpick_forced_key_flag = nil;

    // Sound ids
    pizza_lockpick_sounds = nil;

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

// Init return value
private _return = false;

// ...
switch (true) do 
{

    // The player finished the game and the display is not active (exploit?)
    case (!isNil "pizza_lockpick_picked" && isNull _lock_display): 
    {

        // Remove background blur
        _effect_handle ppEffectEnable false;
        ppEffectDestroy _effect_handle;

        // Return the result of the mini-game (recursive)
        _return = if (pizza_lockpick_picked) then [{true}, {[_difficulty_level, _force_lock_settings, _sweet_spot] call pizza_fnc_hud_lockpick}];

    };

    // The player did not finish the game and the display is not active (escape key?)
    case (isNil "pizza_lockpick_picked" && isNull _lock_display): 
    {

        // Remove background blur
        _effect_handle ppEffectEnable false;
        ppEffectDestroy _effect_handle;

        // Get the return value of the mini-game
        _return = missionNamespace getVariable ["pizza_lockpick_picked", false];
        pizza_lockpick_picked = nil;

    };

    // The player did not finish the game and the display is active (never gonna happen)
    case (isNil "pizza_lockpick_picked" && !isNull _lock_display): 
    {

        // Cleanup mini-game display
        "hud_lockpick" cutRsc ["hud_default", "plain"];

        // Remove background blur
        _effect_handle ppEffectEnable false;
        ppEffectDestroy _effect_handle;

    };

    // The player finished the game and the display is active (normal)
    case (!isNil "pizza_lockpick_picked" && !isNull _lock_display):
    {

        // Wait a second for sounds/animations to finish
        uiSleep 1;

        // Cleanup mini-game display
        "hud_lockpick" cutRsc ["hud_default", "plain"];

        // Remove background blur
        _effect_handle ppEffectEnable false;
        ppEffectDestroy _effect_handle;

        // Return the result of the mini-game (recursive)
        _return = if (pizza_lockpick_picked) then [{true}, {[_difficulty_level, _force_lock_settings, _sweet_spot] call pizza_fnc_hud_lockpick}];

    };

};

// Return
_return;
