disableSerialization;

// Author: Pizza Man
// File: fn_hud_lockpick.sqf
// Description: A skyrim style lockpicking mini-game.

// Image paths
#define IMAGE_INTACT_LOCKPICK "images\lock_pick.paa"
#define IMAGE_BROKEN_LOCKPICK "images\lock_pick_broken.paa"

// Create hud and initalize display
("hud_lockpick" call BIS_fnc_rscLayer) cutRsc ["hud_default", "plain"];
("hud_lockpick" call BIS_fnc_rscLayer) cutRsc ["hud_lockpick", "plain"];
private _display = uiNamespace getVariable ["hud_lockpick", displayNull];
if (isNull _display) exitWith {};

// Init global variables
pizza_lockpick_sweet_spot = (random 180) - 90;
pizza_lockpick_unstable_duration = 0;
pizza_lockpick_force_chance = 0.20;
pizza_lockpick_rotate_lock = false;
pizza_lockpick_rotate_pick = 0;
pizza_lockpick_picked = nil;

// Controls
private _lock_pick_picture = _display displayCtrl 1001;
private _controls_list = _display displayCtrl 1003;

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

// Mini-game logic
["hud_lockpick", "onEachFrame", {

    // Find display and init time since last frame
    private _display = uiNamespace getVariable ["hud_lockpick", displayNull];
    if (isNull _display) exitWith {};

    // Controls
    private _lock_inner_picture = _display displayCtrl 1000;
    private _lock_pick_picture = _display displayCtrl 1001;
    private _lock_pick_proxy = _display displayCtrl 1002;

    // Mini-game completed
    if (!isNil "pizza_lockpick_picked") exitWith {

        // Visually update lockpick based on pick success 
        _lock_pick_picture ctrlSetText ([IMAGE_BROKEN_LOCKPICK, IMAGE_INTACT_LOCKPICK] select pizza_lockpick_picked);

        // Stop mini-game logic
        ["hud_lockpick", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
    };

    // Init basic info
    private _rotation_speed = 1; // Seconds
    private _rotation_amount = 90; // Degrees
    private _lockpick_difficult = 10; // Degrees
    private _lockpick_shake_amount = 1; // Degrees
    private _lockpick_max_unstable_duration = 1; // Seconds
    private _delta = diag_deltaTime; // Seconds

    call {

        // Calculate next inner lock angle
        private _lock_current_angle = ((ctrlAngle _lock_inner_picture) select 0) % 360;
        private _next_lock_angle_difference = -(_rotation_amount * (_delta / _rotation_speed));
        if (pizza_lockpick_rotate_lock) then {_next_lock_angle_difference = abs _next_lock_angle_difference};
        private _next_lock_angle = _lock_current_angle + _next_lock_angle_difference;

        // Calculate max allowed lock rotation
        private _pick_current_angle = ((ctrlAngle _lock_pick_proxy) select 0) % 360;
        private _sweet_spot_padding = [pizza_lockpick_sweet_spot - (_lockpick_difficult / 2), pizza_lockpick_sweet_spot + (_lockpick_difficult / 2)];
        private _distance_to_sweet_spot = (abs (_pick_current_angle - (_sweet_spot_padding select 0))) min (abs (_pick_current_angle - (_sweet_spot_padding select 1)));
        if ((_pick_current_angle >= (_sweet_spot_padding select 0)) && (_pick_current_angle <= (_sweet_spot_padding select 1))) then {_distance_to_sweet_spot = 0};
        private _max_lock_roation_percentage = abs (1 - (_distance_to_sweet_spot / 180));
        private _max_lock_roation = 90 * _max_lock_roation_percentage;
        _next_lock_angle = (_next_lock_angle max 0) min _max_lock_roation;

        // Rotate the inner lock
        _lock_inner_picture ctrlSetAngle [_next_lock_angle, 0.5, 0.5];

        // Calculate pick position
        private _offset_radius = 0.01;
        private _pick_offset_x = _offset_radius * (cos (_next_lock_angle + 90));
        private _pick_offset_y = _offset_radius * (sin (_next_lock_angle + 90));

        // Update pick position
        (ctrlPosition _lock_pick_picture)  params ["_", "_", "_pick_pos_w", "_pick_pos_h"];
        (ctrlPosition _lock_inner_picture) params ["_lock_pos_x", "_lock_pos_y", "_lock_pos_w", "_lock_pos_h"];
        _lock_pick_picture ctrlSetPositionX ((_lock_pos_x + (_lock_pos_w / 2) - (_pick_pos_w / 1.975)) + _pick_offset_x);
        _lock_pick_picture ctrlSetPositionY ((_lock_pos_y + (_lock_pos_h / 2) - (_pick_pos_h / 2.050)) + _pick_offset_y);
        _lock_pick_picture ctrlCommit 0;

        // Lockpick success
        if (_next_lock_angle isEqualTo 90) exitWith {pizza_lockpick_picked = true};

        // Calculate pick break area
        private _pick_unstable_angle = if (_max_lock_roation_percentage isEqualTo 1) then {1000} else {_max_lock_roation * 0.6666};

        // Check if the pick is unstable
        if (_next_lock_angle > _pick_unstable_angle) then {

            // Shake the lock-pick and update lockpick unstable duration
            _lock_pick_picture ctrlSetAngle [_pick_current_angle + ((random (_lockpick_shake_amount * 2)) - _lockpick_shake_amount), 0.5, 0.4875];
            if (pizza_lockpick_rotate_lock) then {pizza_lockpick_unstable_duration = pizza_lockpick_unstable_duration + _delta};

            // Check if the lockpick broke
            if (pizza_lockpick_unstable_duration >= _lockpick_max_unstable_duration) exitWith {pizza_lockpick_picked = false};
        } else {

            // Reset the lock-pick and update lockpick unstable duration
            _lock_pick_picture ctrlSetAngle [_pick_current_angle, 0.5, 0.4875];
            pizza_lockpick_unstable_duration = 0;
        };
    };

    call {

        // Check to rotate lick-pick
        if !(pizza_lockpick_rotate_lock) then {
            if !(pizza_lockpick_rotate_pick isEqualTo 0) then {

                // Calculate next lick-pick angle
                private _pick_current_angle = ((ctrlAngle _lock_pick_picture) select 0) % 360;
                private _next_angle_difference = -(_rotation_amount * (_delta / _rotation_speed));
                if (pizza_lockpick_rotate_pick isEqualTo 2) then {_next_angle_difference = abs _next_angle_difference};
                private _next_angle = _pick_current_angle + _next_angle_difference;
                _next_angle = (_next_angle min 90) max -90;

                // Rotate the lock-pick and its proxy
                _lock_pick_picture ctrlSetAngle [_next_angle, 0.5, 0.4875];
                _lock_pick_proxy ctrlSetAngle [_next_angle, 0.5, 0.5];
            };
        };
    };
}] call BIS_fnc_addStackedEventHandler;

// Cleanup mini-game
_display displayAddEventHandler ["Unload", {

    // Delete global variables
    pizza_lockpick_sweet_spot = nil;
    pizza_lockpick_unstable_duration = nil;
    pizza_lockpick_force_chance = nil;
    pizza_lockpick_rotate_lock = nil;
    pizza_lockpick_rotate_pick = nil;

    // Stop mini-game logic
    ["hud_lockpick", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
}];

// Wait until mini-game is complete and init return value
waitUntil {(isNull _display) || (!isNil "pizza_lockpick_picked")};
if (!isNull _display) then {uiSleep 1; ("hud_lockpick" call BIS_fnc_rscLayer) cutRsc ["hud_default", "plain"]};
private _return = missionNamespace getVariable ["pizza_lockpick_picked", false];
pizza_lockpick_picked = nil;

// Remove background blur
_effect_handle ppEffectEnable false;
ppEffectDestroy _effect_handle;

// Return
_return;
