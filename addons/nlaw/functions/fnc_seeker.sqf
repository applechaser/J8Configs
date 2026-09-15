/* Framework seeker: short-range proximity sensing and fuze only.
 * Always returns no guidance target. No stock ACE NLAW functions are called.
 * Swept 0.25 m samples prevent tunnelling; each sample must be >=20 m from
 * launch. The first FIRE/VIEW surface blocks the sensor, including buildings.
 */
params ["", "_args", "_state"];
private _projectile = (_args select 0) select 6;
if (!local _projectile || {!alive _projectile}) exitWith { [0, 0, 0] };
_state params ["_lastPos", "_lastSpeed", "_origin", "_overfly", "_detonated", "_remaining"];
if (!_overfly || {_detonated}) exitWith { [0, 0, 0] };
private _position = getPosASL _projectile;
private _segment = _position vectorDiff _lastPos;
private _length = vectorMagnitude _segment;
private _speed = vectorMagnitude velocity _projectile;
// Derive transit time from missile motion, not wall-clock/CBA scheduling.
// Velocity is metres per simulation second at every accTime setting.
private _segmentSpeed = 1 max ((_lastSpeed + _speed) * 0.5);
if (_length < 0.00001) exitWith { [0, 0, 0] };
private _down = (vectorUp _projectile) vectorMultiply -1;
private _steps = 1 max (ceil (_length / 0.25));
private _burst = [];
private _burstDistance = if (_remaining >= 0) then {_remaining * _segmentSpeed} else {-1};
for "_i" from 0 to _steps do {
    private _fraction = _i / _steps;
    private _sample = _lastPos vectorAdd (_segment vectorMultiply _fraction);
    private _sampleDistance = _length * _fraction;
    if (_burstDistance >= 0 && {_sampleDistance >= _burstDistance}) exitWith {
        // Place the burst at its sub-frame travel distance.
        private _burstFraction = 0 max ((_burstDistance / _length) min 1);
        _burst = _lastPos vectorAdd (_segment vectorMultiply _burstFraction);
    };
    if (_burstDistance < 0 && {_sample distance _origin >= 20}) then {
        private _hits = lineIntersectsSurfaces [
            _sample, _sample vectorAdd (_down vectorMultiply 5),
            _projectile, objNull, true, 1, "FIRE", "VIEW"
        ];
        if (_hits isNotEqualTo []) then {
            (_hits select 0) params ["", "", "_object", "_parent"];
            if (!isNull _parent) then { _object = _parent; };
            if (_object isKindOf "Tank" || {_object isKindOf "Car"} || {_object isKindOf "Air"}) then {
                // Local sensor delay; never reads the detected object's motion.
                _burstDistance = _sampleDistance + 0.0075 * _segmentSpeed;
            };
        };
    };
};
_state set [0, _position];
_state set [1, _speed];
_state set [5, if (_burstDistance < 0) then {-1} else {0 max ((_burstDistance - _length) / _segmentSpeed)}];
if (_burst isNotEqualTo []) then {
    _state set [4, true]; // Latch before creating ammunition or triggering events.
    private _parents = getShotParents _projectile;
    private _forward = vectorDir _projectile;
    _projectile setPosASL _burst;
    triggerAmmo _projectile;
    private _jet = createVehicle ["ACE_NLAW_Penetrator", ASLToAGL _burst, [], 0, "CAN_COLLIDE"];
    _jet setPosASL _burst;
    _jet setVectorDirAndUp [_down, _forward];
    _jet setShotParents _parents;
    _jet setVelocity (_down vectorMultiply getNumber (configOf _jet >> "typicalSpeed"));
};
[0, 0, 0]
