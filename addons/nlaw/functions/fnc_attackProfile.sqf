/* Framework attack profile: return a real aim position in world ASL.
 * PLOS prediction and DA/OTA trajectory shaping belong here exclusively.
 * The seeker position is deliberately unused: this weapon has no homing.
 */
params ["", "_args", "_state"];
private _projectile = (_args select 0) select 6;
if (!alive _projectile) exitWith { [0, 0, 0] };
_state params ["_launchTime", "_origin", "_yaw", "_pitch", "_yawRate", "_pitchRate", "_overfly"];
private _elapsed = 0 max ((missionNamespace getVariable ["J8_nlaw_simTime", 0]) - _launchTime);
private _distance = (getPosASL _projectile) distance _origin;
private _velocity = velocity _projectile;
private _currentYaw = _yaw + _yawRate * _elapsed;
private _currentPitch = _pitch + _pitchRate * _elapsed;
private _direction = [1, _currentYaw, _currentPitch] call CBA_fnc_polar2vect;
private _radialDirection = if (_distance > 0.01) then {
    _origin vectorFromTo getPosASL _projectile
} else { _direction };
private _radialSpeed = 40 max (_velocity vectorDotProduct _radialDirection);
private _yawRadians = _yawRate * 0.0174532925;
private _pitchRadians = _pitchRate * 0.0174532925;
private _cy = cos _currentYaw;
private _sy = sin _currentYaw;
private _cp = cos _currentPitch;
private _sp = sin _currentPitch;
private _directionRate = [
    _cp * _cy * _yawRadians - _sp * _sy * _pitchRadians,
    -_cp * _sy * _yawRadians - _sp * _cy * _pitchRadians,
    _cp * _pitchRadians
];
// A tangent aimpoint gives the correct instantaneous path direction. A chord
// to a future point cuts across the curve and biases the programmed lead.
private _pathVelocity = (_direction vectorMultiply _radialSpeed) vectorAdd (_directionRate vectorMultiply _distance);
// Command the overfly line itself. Navigation controls the physical rise;
// extrapolating the derivative of a short climb creates a false altitude hump.
private _height = [0, 1] select _overfly;
private _reference = (_origin vectorAdd (_direction vectorMultiply _distance)) vectorAdd [0, 0, _height];
_reference vectorAdd (_pathVelocity vectorMultiply 0.12)
