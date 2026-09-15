/* Framework navigation: own-motion feedback and an ASL profile aimpoint.
 * ACE applies the returned world-space body yaw/pitch rate (degrees/s).
 */
params ["_args","_dt","","_aimPos","","_state"];
if (_dt <= 0) exitWith {[0,0,0]};
private _m = (_args select 0) select 6;
(_args select 2) params ["_pitchLimit","_yawLimit"];
private _velocity = velocity _m;
private _speed = 1 max vectorMagnitude _velocity;
private _localVelocity = _m vectorWorldToModel _velocity;
private _aim = _m vectorWorldToModel (_aimPos vectorDiff getPosASL _m);
if (_state isEqualTo []) then {
    { _state set [_forEachIndex,_x]; } forEach [_velocity,getPosASL _m,2.5,_aimPos,[],[0,0,0],0];
};
_state params ["_lastVelocity","_lastPosition","_response","_lastAim","_lastPath","_pathRate","_interval"];
private _position = getPosASL _m;
private _motionStep = (_position distance _lastPosition)/(1 max ((_speed+vectorMagnitude _lastVelocity)*0.5));
if (_motionStep >= 0.003) then {
    // Current body attitude is the servo position applied during this interval.
    private _flight = vectorNormalized (_velocity vectorAdd _lastVelocity);
    private _body = vectorDir _m;
    private _slip = _body vectorDiff (_flight vectorMultiply (_body vectorDotProduct _flight));
    private _denominator = _slip vectorDotProduct _slip;
    if (_denominator > 0.00003) then {
        private _acceleration = ((_velocity vectorDiff _lastVelocity) vectorMultiply (1/_motionStep)) vectorDiff [0,0,-9.80665];
        private _measured = (_acceleration vectorDotProduct _slip)/(_speed*_denominator);
        _measured = 1 max (_measured min 30);
        _response = _response + (1-exp(-_motionStep/0.04))*(_measured-_response);
    };
    _lastVelocity = _velocity;
    _lastPosition = _position;
};
private _movement = _aimPos vectorDiff _lastAim;
_interval = _interval + _dt;
if (_interval >= 0.05 && {vectorMagnitude _movement > 0.00001}) then {
    private _path = vectorNormalized _movement;
    if (_lastPath isNotEqualTo []) then {
        private _rate = (_lastPath vectorCrossProduct _path) vectorMultiply (57.2957795/_interval);
        _pathRate = _pathRate vectorAdd ((_rate vectorDiff _pathRate) vectorMultiply (1-exp(-_interval/0.08)));
    };
    _lastPath = _path;
    _lastAim = _aimPos;
    _interval = 0;
};
{ _state set [_forEachIndex,_x]; } forEach [_lastVelocity,_lastPosition,_response,_lastAim,_lastPath,_pathRate,_interval];
private _vy = (_localVelocity select 0) atan2 (_localVelocity select 1);
private _vp = (_localVelocity select 2) atan2 (vectorMagnitude [_localVelocity select 0,_localVelocity select 1,0]);
private _ey = [((_aim select 0) atan2 (_aim select 1))-_vy] call CBA_fnc_simplifyAngle180;
private _ep = ((_aim select 2) atan2 (vectorMagnitude [_aim select 0,_aim select 1,0]))-_vp;
private _feed = _m vectorWorldToModel _pathRate;
private _gravity = _m vectorWorldToModel [0,0,-9.80665];
// Use the measured airframe response for the motor and coast phases.
private _bodyGain = 10 max (75-_response);
private _flightGain = 1875/_bodyGain;
private _yawSlip = (_flightGain*_ey-(_feed select 2)-57.2957795*(_gravity select 0)/_speed)/_response;
private _pitchSlip = (_flightGain*_ep+(_feed select 0)-57.2957795*(_gravity select 2)/_speed)/_response;
// Bound angle of attack before the servo. A saturated body-rate command must
// not accumulate a large nose-up angle before the motor starts.
_yawSlip = -4.5 max (_yawSlip min 4.5);
_pitchSlip = -4.5 max (_pitchSlip min 4.5);
// Exact first-order servo integration keeps the body loop stable on long frames.
private _servo = (1-exp(-_bodyGain*_dt))/_dt;
private _yaw = _servo*(_vy+_yawSlip);
private _pitch = _servo*(_vp+_pitchSlip);
_m vectorModelToWorld [(-_yawLimit max _yaw) min _yawLimit,0,(-_pitchLimit max _pitch) min _pitchLimit]
