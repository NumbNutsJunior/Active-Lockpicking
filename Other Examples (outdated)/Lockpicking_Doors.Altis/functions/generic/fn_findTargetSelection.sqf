
// Author: Pizza Man & wiki example
// File: fn_findTargetSelection.sqf
// Description: Return the selection name of current camera target.

// Find object at center of screen (similar to cursorObject)
private _ray_begin = AGLToASL (positionCameraToWorld [0,0,0]);
private _ray_end = AGLToASL (positionCameraToWorld [0,0,100]);
private _parent_object_intersections = lineIntersectsSurfaces [_ray_begin, _ray_end, vehicle player, player, true, 1, "FIRE", "NONE"];
if ((count _parent_object_intersections) isEqualTo 0) exitWith {[objNull, "", []]};

// Check if intersected object contains indexable pieces (skeleton)
private _parent_object = (_parent_object_intersections select 0) param [3, objNull];
if !((getModelInfo _parent_object) select 2) exitWith {[objNull, "", []]};

// Check if initial ray intersected any selections of parent object's skeleton
private _skeleton_intersections = [_parent_object, "FIRE"] intersect [ASLToAGL _ray_begin, ASLToAGL _ray_end];
if ((count _skeleton_intersections) isEqualTo 0) exitWith {[objNull, "", []]};

// Select door from object's selection names
(_skeleton_intersections select 0) params [["_selection", ""]];
if (_selection isEqualTo "") exitWith {[objNull, "", []]};

// Return
[_parent_object, _selection, _parent_object selectionPosition _selection];