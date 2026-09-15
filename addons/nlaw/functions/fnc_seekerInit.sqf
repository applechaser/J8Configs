// Framework seeker onFired: initialize the local proximity or impact fuze.
params ["_firedEH", "_launchParams", "", "", "_states"];
private _position = getPosASL (_firedEH select 6);
private _state = _states select 1;
{ _state set [_forEachIndex, _x]; } forEach [
    _position, vectorMagnitude velocity (_firedEH select 6),
    (_launchParams select 3) == "ace_nlaw_overflyTopAttack", false, -1, 0.2 // Shared DA/OTA arming delay, simulation seconds.
];

private _projectile = _firedEH select 6;
if (!local _projectile || {_state select 2}) exitWith {};
_projectile setVariable ["J8_nlaw_armed", false];
_projectile addEventHandler ["HitPart", {
    params ["_projectile", "", "", "_position", "_velocity"];
    // One jet per impact, spawned outside the armour so penetration is simulated.
    _projectile removeEventHandler ["HitPart", _thisEventHandler];
    if !(_projectile getVariable ["J8_nlaw_armed", false]) exitWith {};
    private _direction = vectorNormalized _velocity;
    if (_direction isEqualTo [0, 0, 0]) then { _direction = vectorDir _projectile; };
    private _spawn = _position vectorDiff (_direction vectorMultiply 0.2);
    private _jet = createVehicle ["ACE_NLAW_Penetrator", ASLToAGL _spawn, [], 0, "CAN_COLLIDE"];
    _jet setPosASL _spawn;
    _jet setVectorDirAndUp [_direction, vectorUp _projectile];
    _jet setShotParents (getShotParents _projectile);
    _jet setVelocity (_direction vectorMultiply getNumber (configOf _jet >> "typicalSpeed"));
}];
